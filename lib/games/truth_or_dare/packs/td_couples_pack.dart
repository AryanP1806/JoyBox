import '../truth_dare_models.dart';

const List<TruthDareQuestion> couplesTruths = [
  TruthDareQuestion(
    text: "What was your first impression of your partner?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "What is one thing your partner does that you secretly love?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "What is your biggest relationship green flag?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Is there something you wish you did more together?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Have you ever gotten jealous and pretended you weren't?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "What is the pettiest reason you've ever started a fight?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text:
        "If we broke up today, what is the one thing you would miss the most?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Who is your partner's most annoying friend/relative?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Rate your partner's kissing skills on a scale of 1 to 10.",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "What is a secret fantasy you have never told your partner?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.couples,
  ),
];

const List<TruthDareQuestion> couplesDares = [
  TruthDareQuestion(
    text: "Give your partner a genuine 10-second hug.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Hold hands with your partner until your next turn.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Say three things you are grateful for about your partner.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text:
        "Let your partner ask you any one question (you must answer honestly).",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Recreate your first photo pose together.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Let your partner give you a makeover (hair or makeup).",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Give your partner a 2-minute foot massage.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Serenade your partner with a romantic song (bad singing allowed).",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Whisper something very seductive in your partner's ear.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
  TruthDareQuestion(
    text: "Post a picture of your partner on your story with a cheesy caption.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.couples,
  ),
];

class CouplesPack {
  static List<TruthDareQuestion> getTruths() => couplesTruths;
  static List<TruthDareQuestion> getDares() => couplesDares;
}
