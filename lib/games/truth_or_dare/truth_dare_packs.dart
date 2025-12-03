import 'truth_dare_models.dart';
import '../../storage/truth_dare_local_storage.dart';
import '../../settings/app_settings.dart'; // ✅ ADD THIS

import 'packs/td_friends_pack.dart';
import 'packs/td_family_pack.dart';
import 'packs/td_couples_pack.dart';
import 'packs/td_adult_pack.dart';

class TruthDarePacks {
  // ✅ ASYNC because CustomPack is async (SharedPreferences)
  static Future<List<TruthDareQuestion>> getTruths(
    TruthDareCategory category,
  ) async {
    switch (category) {
      case TruthDareCategory.friends:
        return friendsTruths;

      case TruthDareCategory.family:
        return familyTruths;

      case TruthDareCategory.couples:
        return couplesTruths;

      case TruthDareCategory.adult:
        if (!AppSettings.instance.adultEnabled) return [];
        return adultTruths;

      case TruthDareCategory.custom:
        final list = await TruthDareLocalStorage.getTruths();
        return list
            .map(
              (t) => TruthDareQuestion(
                text: t,
                type: TruthOrDareChoice.truth,
                category: TruthDareCategory.custom,
              ),
            )
            .toList();
    }
  }

  // ✅ ASYNC here as well
  static Future<List<TruthDareQuestion>> getDares(
    TruthDareCategory category,
  ) async {
    switch (category) {
      case TruthDareCategory.friends:
        return friendsDares;

      case TruthDareCategory.family:
        return familyDares;

      case TruthDareCategory.couples:
        return couplesDares;

      case TruthDareCategory.adult:
        if (!AppSettings.instance.adultEnabled) return [];
        return adultDares;

      case TruthDareCategory.custom:
        final list = await TruthDareLocalStorage.getDares();
        return list
            .map(
              (d) => TruthDareQuestion(
                text: d,
                type: TruthOrDareChoice.dare,
                category: TruthDareCategory.custom,
              ),
            )
            .toList();
    }
  }
}
