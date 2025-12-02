//import '../../truth_dare_models.dart';
import '../truth_dare_models.dart';

/// Friends mode – silly, fun, not too deep.
/// You can expand this list later.
const List<TruthDareQuestion> friendsTruths = [
  TruthDareQuestion(
    text: "What is the most embarrassing thing you've ever done in public?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Who in this room would you trust with your biggest secret?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "What is one habit you have that annoys other people?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Who was your first crush?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "What’s the dumbest thing you’ve done to impress someone?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
];

const List<TruthDareQuestion> friendsDares = [
  TruthDareQuestion(
    text: "Speak in a fake accent until your next turn.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Let the group change your hairstyle for one round.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Do your best impression of a teacher from your college/school.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Swap your phone wallpaper to a funny picture chosen by the group.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Do an overdramatic Bollywood dialogue of your choice.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
];

class FriendsPack {
  static List<TruthDareQuestion> getTruths() => friendsTruths;
  static List<TruthDareQuestion> getDares() => friendsDares;
}
