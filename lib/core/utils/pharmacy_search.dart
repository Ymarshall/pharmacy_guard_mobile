import '../../features/pharmacy/domain/entities/pharmacy.dart';

/// Recherche texte tolérante pour les pharmacies.
///
/// - insensible à la casse et aux accents (« Bonne Santé » = « bonne sante ») ;
/// - recherche partielle : chaque mot tapé doit apparaître quelque part ;
/// - abréviations courantes : ST/STE → saint/sainte, PHCIE/PHIE/PHARM → pharmacie ;
/// - porte sur le nom, la commune, la ville, le quartier/district et la description.
class PharmacySearch {
  PharmacySearch._();

  static const Map<String, String> _accents = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
    'œ': 'oe', 'æ': 'ae',
  };

  static const Map<String, String> _abbreviations = {
    'st': 'saint',
    'ste': 'sainte',
    'phcie': 'pharmacie',
    'phie': 'pharmacie',
    'pharma': 'pharmacie',
    'pharm': 'pharmacie',
    'ph': 'pharmacie',
  };

  /// Minuscules, sans accents, ponctuation → espaces, abréviations développées.
  static String normalize(String? input) {
    if (input == null || input.isEmpty) return '';
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final mapped = _accents[char] ?? char;
      if (RegExp(r'[a-z0-9]').hasMatch(mapped)) {
        buffer.write(mapped);
      } else {
        buffer.write(' ');
      }
    }
    return buffer
        .toString()
        .split(' ')
        .where((t) => t.isNotEmpty)
        .map((t) => _abbreviations[t] ?? t)
        .join(' ');
  }

  static List<String> _tokens(String query) =>
      normalize(query).split(' ').where((t) => t.isNotEmpty).toList();

  static String _haystack(Pharmacy p) => normalize(
    [
      p.name,
      p.commune,
      p.city,
      p.district,
      p.description,
      p.pharmacistName,
    ].whereType<String>().join(' '),
  );

  /// `true` si tous les mots de [query] se retrouvent dans la pharmacie.
  static bool matches(Pharmacy pharmacy, String query) {
    final tokens = _tokens(query);
    if (tokens.isEmpty) return true;
    final haystack = _haystack(pharmacy);
    final phones = [pharmacy.phone1, pharmacy.phone2]
        .whereType<String>()
        .map((p) => p.replaceAll(RegExp(r'\D'), ''))
        .join(' ');
    return tokens.every((token) {
      if (haystack.contains(token)) return true;
      final digits = token.replaceAll(RegExp(r'\D'), '');
      return digits.length >= 4 && phones.contains(digits);
    });
  }

  /// Score de pertinence (plus haut = plus pertinent) pour trier les résultats.
  static int score(Pharmacy pharmacy, String query) {
    final q = normalize(query);
    final name = normalize(pharmacy.name);
    if (q.isEmpty) return 0;
    if (name == q || name == 'pharmacie $q') return 100;
    final words = name.split(' ');
    var score = 0;
    for (final token in _tokens(query)) {
      if (words.contains(token)) {
        score += 20;
      } else if (words.any((w) => w.startsWith(token))) {
        score += 10;
      } else if (name.contains(token)) {
        score += 5;
      }
    }
    return score;
  }

  /// Filtre et trie par pertinence (stable pour les égalités).
  static List<T> filter<T extends Pharmacy>(List<T> pharmacies, String query) {
    if (_tokens(query).isEmpty) return List<T>.of(pharmacies);
    final indexed = <(int, T)>[];
    for (var i = 0; i < pharmacies.length; i++) {
      if (matches(pharmacies[i], query)) indexed.add((i, pharmacies[i]));
    }
    indexed.sort((a, b) {
      final byScore = score(b.$2, query).compareTo(score(a.$2, query));
      return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
    });
    return indexed.map((e) => e.$2).toList();
  }
}
