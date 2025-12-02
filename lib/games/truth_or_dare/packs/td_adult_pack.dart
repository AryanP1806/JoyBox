import '../truth_dare_models.dart';

/// Keep it suggestive / party style, not explicit.
/// You can replace texts with your own later.
const List<TruthDareQuestion> adultTruths = [
  TruthDareQuestion(
    text: "Have you ever had a crush on someone here?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "What is your biggest red flag in someone you like?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "What is the boldest thing you've ever done for attention?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Have you ever sent a risky message and regretted it?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Who here do you think flirts the most?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Have you ever stalked an ex on social media from a fake account?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "What is the strangest place you've ever hooked up?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text:
        "If you had to date someone in this room (other than your partner), who would it be?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text:
        "What is your biggest 'turn-off' that most people think is a 'turn-on'?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Have you ever ghosted someone after a good date?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
];

const List<TruthDareQuestion> adultDares = [
  TruthDareQuestion(
    text: "Let someone go through your memes folder for 30 seconds.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Share the last DM you received (you can hide the name).",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Let the group change your social media status for 1 minute.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text:
        "Let someone else send a harmless emoji to a contact of their choice.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Act out a dramatic romantic scene with someone chosen by the group.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Remove one item of clothing (accessories/shoes count).",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Text your crush (or an ex) saying 'I had a dream about you'.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Do your best 'sexy walk' across the room.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Sit on the lap of the person to your right for the next round.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
  TruthDareQuestion(
    text: "Read the last text message you sent out loud in a seductive voice.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.adult,
    isAdult: true,
  ),
];

class AdultPack {
  static List<TruthDareQuestion> getTruths() => adultTruths;
  static List<TruthDareQuestion> getDares() => adultDares;
}
