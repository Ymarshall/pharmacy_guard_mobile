import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../pharmacy/presentation/widgets/pharmacy_card.dart';
import '../../../pharmacy/presentation/pages/pharmacy_detail_page.dart';
import '../../../pharmacy/domain/entities/pharmacy.dart';
import '../../../pharmacy/data/models/pharmacy_model.dart';
import '../../../pharmacy/presentation/providers/pharmacy_notifier.dart';
import '../../../emergency/presentation/pages/emergency_numbers_page.dart';
import '../../../../core/utils/distance_utils.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../../core/providers/providers.dart' as providers;
import '../widgets/search_bar_widget.dart';
import '../widgets/emergency_button.dart';
import '../widgets/app_drawer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _city;
  String? _commune;
  List<Pharmacy> _allPharmacies = []; // Liste totale pour la recherche
  bool _isLoadingAllPharmacies = false;

  @override
  void initState() {
    super.initState();
    // Initialiser avec des valeurs par défaut
    _initializeDefaultLocation();
    // Charger les pharmacies de garde les plus proches après que le widget tree soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearestDutyPharmacies();
    });
    // Essayer de récupérer la localisation en arrière-plan
    _getCurrentLocation();
  }

  Future<void> _initializeDefaultLocation() async {
    // Utiliser la position du client depuis l'auth si disponible
    final authState = ref.read(authNotifierProvider);
    final latitude = authState.authResponse?.client.latitude;
    final longitude = authState.authResponse?.client.longitude;
    if (latitude != null && longitude != null) {
      setState(() {
        _latitude = latitude;
        _longitude = longitude;
      });

      final geocodingService = GeocodingServiceImpl();
      final locationInfo = await geocodingService.getLocationInfo(
        latitude,
        longitude,
      );

      setState(() {
        _city = locationInfo.city;
        _commune = locationInfo.commune;
      });
    } else {
      // Valeurs par défaut si pas d'auth
      final geocodingService = GeocodingServiceImpl();
      final defaultLat = 5.3600;
      final defaultLng = -4.0083;
      final locationInfo = await geocodingService.getLocationInfo(
        defaultLat,
        defaultLng,
      );

      setState(() {
        _city = locationInfo.city;
        _commune = locationInfo.commune;
      });
    }
  }

  Future<void> _loadNearestDutyPharmacies() async {
    // Déterminer les coordonnées à utiliser
    final authState = ref.read(authNotifierProvider);
    final userLat =
        _latitude ?? authState.authResponse?.client.latitude ?? 5.3600;
    final userLng =
        _longitude ?? authState.authResponse?.client.longitude ?? -4.0083;

    // Charger les 3 pharmacies de garde les plus proches depuis l'API
    await ref
        .read(pharmacyNotifierProvider.notifier)
        .getNearestDutyPharmacies(
          latitude: userLat,
          longitude: userLng,
          limit: 3,
        );
  }

  Future<void> _loadAllPharmaciesForSearch() async {
    // Charger toutes les pharmacies depuis l'API pour permettre la recherche
    if (_allPharmacies.isEmpty && !_isLoadingAllPharmacies) {
      setState(() {
        _isLoadingAllPharmacies = true;
      });

      try {
        // Utiliser directement le repository pour récupérer toutes les pharmacies
        final repository = ref.read(providers.pharmacyRepositoryProvider);
        final result = await repository.getAllPharmacies();

        result.fold(
          (failure) {
            setState(() {
              _isLoadingAllPharmacies = false;
            });
          },
          (pharmacies) {
            setState(() {
              _allPharmacies = pharmacies;
              _isLoadingAllPharmacies = false;
            });
          },
        );
      } catch (e) {
        setState(() {
          _isLoadingAllPharmacies = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = LocationServiceImpl();
      final position = await locationService.getCurrentLocation();

      // Obtenir les informations de localisation (ville, commune)
      final geocodingService = GeocodingServiceImpl();
      final locationInfo = await geocodingService.getLocationInfo(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _city = locationInfo.city;
        _commune = locationInfo.commune;
      });

      // Recharger les pharmacies de garde les plus proches avec la nouvelle position
      await _loadNearestDutyPharmacies();
    } catch (e) {
      // En cas d'erreur, utiliser les valeurs par défaut
      final geocodingService = GeocodingServiceImpl();
      final defaultLat = _latitude ?? 5.3600;
      final defaultLng = _longitude ?? -4.0083;
      final locationInfo = await geocodingService.getLocationInfo(
        defaultLat,
        defaultLng,
      );

      setState(() {
        _city = locationInfo.city;
        _commune = locationInfo.commune;
      });
    }
  }

  void _onSearch(String query) async {
    if (query.isNotEmpty) {
      // Charger toutes les pharmacies si pas déjà chargées
      await _loadAllPharmaciesForSearch();
    } else {
      // Si le champ est vide, recharger les pharmacies de garde les plus proches
      await _loadNearestDutyPharmacies();
    }
    setState(() {
      // Le filtrage sera fait dans le build
    });
  }

  List<Pharmacy> _getFilteredAndSortedPharmacies(
    List<Pharmacy> pharmacies,
    String query,
  ) {
    // Filtrer les pharmacies selon la recherche
    List<Pharmacy> filtered = pharmacies;
    if (query.isNotEmpty) {
      final queryLower = query.toLowerCase().trim();
      filtered =
          pharmacies.where((pharmacy) {
            // Recherche par nom
            if (pharmacy.name.toLowerCase().contains(queryLower)) return true;

            // Recherche par ville
            if (pharmacy.city != null &&
                pharmacy.city!.toLowerCase().contains(queryLower))
              return true;

            // Recherche par commune
            if (pharmacy.commune != null &&
                pharmacy.commune!.toLowerCase().contains(queryLower))
              return true;

            // Recherche par district
            if (pharmacy.district != null &&
                pharmacy.district!.toLowerCase().contains(queryLower))
              return true;

            // Recherche par adresse complète
            final address = _getPharmacyAddress(pharmacy);
            if (address.toLowerCase().contains(queryLower)) return true;

            // Recherche par nom du pharmacien
            if (pharmacy.pharmacistName != null &&
                pharmacy.pharmacistName!.toLowerCase().contains(queryLower))
              return true;

            // Recherche par téléphone
            if (pharmacy.phone1.toLowerCase().contains(queryLower)) return true;
            if (pharmacy.phone2 != null &&
                pharmacy.phone2!.toLowerCase().contains(queryLower))
              return true;

            return false;
          }).toList();
    }

    // Trier par proximité si on a une position
    final userLat =
        _latitude ??
        ref.read(authNotifierProvider).authResponse?.client.latitude;
    final userLng =
        _longitude ??
        ref.read(authNotifierProvider).authResponse?.client.longitude;

    if (userLat != null && userLng != null) {
      // Calculer la distance pour chaque pharmacie et trier
      final pharmaciesWithDistance =
          filtered.map((pharmacy) {
            final distance =
                pharmacy.hasGps
                    ? DistanceUtils.distanceIfPossible(
                      userLat,
                      userLng,
                      pharmacy.latitude,
                      pharmacy.longitude,
                    )
                    : null;
            return (pharmacy as PharmacyModel).copyWith(
              distance: distance,
              clearDistance: distance == null,
            );
          }).toList();

      // Trier par distance (les plus proches en premier)
      pharmaciesWithDistance.sort((a, b) {
        final distA = a.distance ?? double.infinity;
        final distB = b.distance ?? double.infinity;
        return distA.compareTo(distB);
      });

      return pharmaciesWithDistance;
    }

    // Si pas de position, retourner sans tri
    return filtered;
  }

  String _getPharmacyAddress(Pharmacy pharmacy) {
    final parts = <String>[];
    if (pharmacy.commune != null && pharmacy.commune!.isNotEmpty) {
      parts.add(pharmacy.commune!);
    }
    if (pharmacy.city != null && pharmacy.city!.isNotEmpty) {
      parts.add(pharmacy.city!);
    }
    if (pharmacy.district != null && pharmacy.district!.isNotEmpty) {
      parts.add(pharmacy.district!);
    }
    return parts.isNotEmpty ? parts.join(', ') : '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyState = ref.watch(pharmacyNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    // Déterminer les coordonnées à utiliser pour calculer la distance
    final userLat = _latitude ?? authState.authResponse?.client.latitude;
    final userLng = _longitude ?? authState.authResponse?.client.longitude;

    // Choisir la liste de pharmacies à utiliser
    // Si recherche active : utiliser toutes les pharmacies
    // Sinon : utiliser les pharmacies de garde les plus proches
    final pharmaciesToUse =
        _searchController.text.isNotEmpty
            ? _allPharmacies
            : pharmacyState.pharmacies;

    // Filtrer et trier les pharmacies selon la recherche et la proximité
    final filteredPharmacies = _getFilteredAndSortedPharmacies(
      pharmaciesToUse,
      _searchController.text,
    );

    final searching = _searchController.text.isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.background,
      drawer: const AppDrawer(),
      floatingActionButton: EmergencyButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmergencyNumbersPage(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: Column(
          children: [
            Container(
              color: context.primaryDark,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.xl2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                () => _scaffoldKey.currentState?.openDrawer(),
                            icon: const Icon(Icons.menu, color: Colors.white),
                            tooltip: 'Menu',
                          ),
                          Expanded(
                            child: Text(
                              'Pharmacie de Garde',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () => _showLogoutDialog(context),
                            tooltip: 'Déconnexion',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Text(
                          searching
                              ? 'Recherche'
                              : 'Pharmacies de garde\nà proximité',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_city != null && _commune != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_commune, $_city',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SearchBarWidget(
                        controller: _searchController,
                        onChanged: _onSearch,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  pharmacyState.isLoading
                      ? const LoadingWidget(
                        message: 'Chargement des pharmacies...',
                      )
                      : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.lg,
                              AppSpacing.lg,
                              AppSpacing.sm,
                            ),
                            child: SectionHeader(
                              eyebrow: searching ? 'Recherche' : 'À proximité',
                              title:
                                  searching
                                      ? '${filteredPharmacies.length} résultat${filteredPharmacies.length > 1 ? 's' : ''}'
                                      : 'Pharmacies de garde',
                            ),
                          ),
                          Expanded(
                            child: _buildPharmacyList(filteredPharmacies),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyList(List<Pharmacy> pharmacies) {
    final authState = ref.read(authNotifierProvider);

    if (pharmacies.isEmpty) {
      return const EmptyState(
        icon: Icons.local_pharmacy_outlined,
        title: 'Aucune pharmacie de garde trouvée',
        message: 'Aucune pharmacie de garde n\'est disponible pour le moment',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: pharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = pharmacies[index];
        final userLat = _latitude ?? authState.authResponse?.client.latitude;
        final userLng = _longitude ?? authState.authResponse?.client.longitude;

        return PharmacyCard(
          pharmacy: pharmacy,
          userLatitude: userLat,
          userLongitude: userLng,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PharmacyDetailPage(
                      pharmacy: pharmacy,
                      userLatitude: userLat,
                      userLongitude: userLng,
                    ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context);
              },
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) {
        context.navigateToAndRemoveUntil(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Erreur lors de la déconnexion');
      }
    }
  }
}
