import '../../../storage/truth_dare_local_storage.dart';
import '../truth_dare_models.dart';

class CustomPack {
  static Future<List<TruthDareQuestion>> getTruths() async {
    final list = await TruthDareLocalStorage.getTruths();

    return list
        .map(
          (t) => TruthDareQuestion(
            text: t,
            type: TruthOrDareChoice.truth,
            category: TruthDareCategory.custom,
            isAdult: false,
          ),
        )
        .toList();
  }

  static Future<List<TruthDareQuestion>> getDares() async {
    final list = await TruthDareLocalStorage.getDares();

    return list
        .map(
          (d) => TruthDareQuestion(
            text: d,
            type: TruthOrDareChoice.dare,
            category: TruthDareCategory.custom,
            isAdult: false,
          ),
        )
        .toList();
  }
}
