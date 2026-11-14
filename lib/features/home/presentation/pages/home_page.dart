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
import '../../../../core/utils/pharmacy_search.dart';
import '../../../../core/errors/exceptions.dart';
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

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _city;
  String? _commune;
  List<Pharmacy> _allPharmacies = []; // Liste totale pour la recherche
  bool _isLoadingAllPharmacies = false;
  String? _searchLoadError;

  /// Raison pour laquelle la position GPS manque (bannière non bloquante).
  LocationIssue? _locationIssue;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialiser avec des valeurs par défaut
    _initializeDefaultLocation();
    // Charger les pharmacies de garde les plus proches après que le widget tree soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearestDutyPharmacies();
      // Précharger la liste complète pour que la recherche soit immédiate.
      _loadAllPharmaciesForSearch();
    });
    // Essayer de récupérer la localisation en arrière-plan, sans reposer
    // la question si l'utilisateur vient d'y répondre à l'inscription.
    _getCurrentLocation(requestPermission: !LocationPrompt.askedThisSession);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Retour des réglages : on retente sans redemander la permission.
    if (state == AppLifecycleState.resumed && _locationIssue != null) {
      _getCurrentLocation(requestPermission: false);
    }
  }

  Future<void> _initializeDefaultLocation() async {
    // Utiliser la position du client depuis l'auth si disponible
    final authState = ref.read(authNotifierProvider);
    final latitude = authState.authResponse?.client.latitude;
    final longitude = authState.authResponse?.client.longitude;
    if (latitude != null && longitude != null) {
      if (!mounted) return;
      setState(() {
        _latitude = latitude;
        _longitude = longitude;
      });

      final geocodingService = GeocodingServiceImpl();
      final locationInfo = await geocodingService.getLocationInfo(
        latitude,
        longitude,
      );

      if (!mounted) return;
      setState(() {
        _city = locationInfo.city;
        _commune = locationInfo.commune;
      });
    } else {
      // Pas de libellé de lieu tant qu'on n'a pas une vraie position.
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
    if (_allPharmacies.isNotEmpty || _isLoadingAllPharmacies) return;
    if (mounted) {
      setState(() {
        _isLoadingAllPharmacies = true;
        _searchLoadError = null;
      });
    }

    String? error;
    List<Pharmacy> loaded = const [];
    try {
      final repository = ref.read(providers.pharmacyRepositoryProvider);
      final result = await repository.getAllPharmacies();
      result.fold(
        (failure) => error = failure.message,
        (pharmacies) => loaded = pharmacies,
      );
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      _allPharmacies = loaded;
      _isLoadingAllPharmacies = false;
      _searchLoadError =
          error == null
              ? null
              : 'Impossible de charger la liste des pharmacies. '
                  'Vérifiez votre connexion.';
    });
  }

  Future<void> _getCurrentLocation({bool requestPermission = true}) async {
    if (_isLocating) return;
    _isLocating = true;
    try {
      final locationService = LocationServiceImpl();
      final position = await locationService.getCurrentLocation(
        requestPermission: requestPermission,
      );
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationIssue = null;
      });

      // Recharger les pharmacies de garde les plus proches avec la nouvelle position
      final reload = _loadNearestDutyPharmacies();

      // Obtenir les informations de localisation (ville, commune)
      try {
        final geocodingService = GeocodingServiceImpl();
        final locationInfo = await geocodingService
            .getLocationInfo(position.latitude, position.longitude)
            .timeout(const Duration(seconds: 10));
        if (mounted) {
          setState(() {
            _city = locationInfo.city;
            _commune = locationInfo.commune;
          });
        }
      } catch (_) {
        // Le libellé du lieu est facultatif.
      }
      await reload;
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() => _locationIssue = e.issue);
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationIssue = LocationIssue.unknown);
    } finally {
      _isLocating = false;
    }
  }

  Future<void> _openLocationSettings() async {
    final issue = _locationIssue ?? LocationIssue.unknown;
    if (issue == LocationIssue.denied) {
      // Refus simple : la boîte système peut être reproposée.
      await _getCurrentLocation();
      return;
    }
    await LocationServiceImpl().openSettingsFor(issue);
  }

  String get _locationIssueMessage {
    switch (_locationIssue) {
      case LocationIssue.serviceDisabled:
        return 'La localisation de votre téléphone est désactivée. '
            'Activez-la pour voir les gardes les plus proches de vous.';
      case LocationIssue.deniedForever:
        return 'L\'accès à votre position est bloqué. Autorisez-le dans les '
            'réglages pour trier les gardes par distance.';
      case LocationIssue.timeout:
        return 'Position introuvable pour le moment. Les gardes ne sont pas '
            'triées par distance.';
      default:
        return 'Autorisez la localisation pour voir les gardes les plus '
            'proches de vous.';
    }
  }

  String get _locationActionLabel {
    switch (_locationIssue) {
      case LocationIssue.serviceDisabled:
      case LocationIssue.deniedForever:
        return 'Ouvrir les réglages';
      case LocationIssue.timeout:
      case LocationIssue.unknown:
        return 'Réessayer';
      default:
        return 'Autoriser';
    }
  }

  Widget _buildLocationBanner(BuildContext context) {
    final issue = _locationIssue;
    final opensSettings =
        issue == LocationIssue.serviceDisabled ||
        issue == LocationIssue.deniedForever;
    return Container(
      key: const ValueKey('location-banner'),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.warningSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_off_outlined,
                  size: 18,
                  color: context.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _locationIssueMessage,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              children: [
                if (opensSettings)
                  TextButton(
                    onPressed: () => _getCurrentLocation(
                      requestPermission: false,
                    ),
                    child: const Text('Réessayer'),
                  ),
                TextButton(
                  onPressed:
                      opensSettings
                          ? _openLocationSettings
                          : () => _getCurrentLocation(),
                  child: Text(_locationActionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSearch(String query) async {
    // Rafraîchir tout de suite l'affichage (résultats ou indicateur de chargement).
    setState(() {});
    if (query.trim().isNotEmpty) {
      // Charger toutes les pharmacies si pas déjà chargées
      await _loadAllPharmaciesForSearch();
    } else if (ref.read(pharmacyNotifierProvider).pharmacies.isEmpty) {
      // Si le champ est vide, recharger les pharmacies de garde les plus proches
      await _loadNearestDutyPharmacies();
    }
  }

  void _retrySearchLoad() {
    setState(() => _allPharmacies = []);
    _loadAllPharmaciesForSearch();
  }

  List<Pharmacy> _getFilteredAndSortedPharmacies(
    List<Pharmacy> pharmacies,
    String query,
  ) {
    final searching = query.trim().isNotEmpty;
    // Recherche tolérante : casse, accents, abréviations (ST, PHCIE…), mots partiels.
    final filtered = PharmacySearch.filter(pharmacies, query);

    // Seule une vraie position (GPS ou position enregistrée du compte)
    // permet d'afficher une distance.
    final userLat =
        _latitude ??
        ref.read(authNotifierProvider).authResponse?.client.latitude;
    final userLng =
        _longitude ??
        ref.read(authNotifierProvider).authResponse?.client.longitude;

    if (userLat == null || userLng == null) {
      return filtered
          .map(
            (pharmacy) =>
                pharmacy is PharmacyModel
                    ? pharmacy.copyWith(clearDistance: true)
                    : pharmacy,
          )
          .toList();
    }

    final withDistance =
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

    final scores = <String, int>{
      if (searching)
        for (final p in withDistance) p.id: PharmacySearch.score(p, query),
    };
    withDistance.sort((a, b) {
      if (searching) {
        final byScore = (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0);
        if (byScore != 0) return byScore;
      }
      final distA = a.distance ?? double.infinity;
      final distB = b.distance ?? double.infinity;
      return distA.compareTo(distB);
    });
    return withDistance;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasLocationLabel => _city != null || _commune != null;

  String get _locationLabel {
    return LocationInfo(
      city: _city ?? '',
      commune: _commune ?? '',
    ).displayLabel;
  }

  @override
  Widget build(BuildContext context) {
    final pharmacyState = ref.watch(pharmacyNotifierProvider);
    // Reconstruire quand la session (et sa position enregistrée) change.
    ref.watch(authNotifierProvider);

    // Choisir la liste de pharmacies à utiliser
    // Si recherche active : utiliser toutes les pharmacies
    // Sinon : utiliser les pharmacies de garde les plus proches
    final pharmaciesToUse =
        _searchController.text.trim().isNotEmpty
            ? _allPharmacies
            : pharmacyState.pharmacies;

    // Filtrer et trier les pharmacies selon la recherche et la proximité
    final filteredPharmacies = _getFilteredAndSortedPharmacies(
      pharmaciesToUse,
      _searchController.text,
    );

    final searching = _searchController.text.trim().isNotEmpty;

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
      body: Column(
        children: [
          Container(
            color: context.primaryDark,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.md,
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
                          visualDensity: VisualDensity.compact,
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
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            searching ? 'Recherche' : 'Gardes à proximité',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (_hasLocationLabel) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _locationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SearchBarWidget(
                      controller: _searchController,
                      onChanged: _onSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_locationIssue != null) _buildLocationBanner(context),
          Expanded(
            child:
                (searching
                        ? (_isLoadingAllPharmacies && _allPharmacies.isEmpty)
                        : pharmacyState.isLoading)
                    ? LoadingWidget(
                      message:
                          searching
                              ? 'Recherche dans toutes les pharmacies...'
                              : 'Chargement des pharmacies...',
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
                          child: _buildPharmacyList(
                            filteredPharmacies,
                            searching: searching,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyList(
    List<Pharmacy> pharmacies, {
    bool searching = false,
  }) {
    final authState = ref.read(authNotifierProvider);

    if (pharmacies.isEmpty && searching) {
      if (_searchLoadError != null && _allPharmacies.isEmpty) {
        return EmptyState(
          icon: Icons.wifi_off_outlined,
          title: 'Recherche indisponible',
          message: _searchLoadError!,
          actionLabel: 'Réessayer',
          onAction: _retrySearchLoad,
        );
      }
      return EmptyState(
        icon: Icons.search_off_outlined,
        title: 'Aucun résultat',
        message:
            'Aucune pharmacie ne correspond à « ${_searchController.text.trim()} ».',
      );
    }

    if (pharmacies.isEmpty) {
      return const EmptyState(
        icon: Icons.local_pharmacy_outlined,
        title: 'Aucune pharmacie de garde trouvée',
        message: 'Aucune pharmacie de garde n\'est disponible pour le moment',
      );
    }

    const fabClearance = kFloatingActionButtonMargin + 56 + 16;
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: fabClearance + MediaQuery.of(context).padding.bottom,
      ),
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
