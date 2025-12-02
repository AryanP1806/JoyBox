import '../truth_dare_models.dart';

const List<TruthDareQuestion> familyTruths = [
  TruthDareQuestion(
    text: "What is your favorite family memory?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Which family member do you go to for advice the most?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "What is one thing you appreciate but rarely say out loud?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "What is one family rule you secretly find useless?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Have you ever lied to avoid a family function?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text:
        "Have you ever borrowed money from someone here and forgot to pay it back?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text:
        "If you had to delete one person from this group from your life, who would it be?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "What is the weirdest rumor you've heard about yourself?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Who in this room do you think has the worst fashion sense?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text:
        "Show the last photo you deleted from your gallery. Why did you delete it?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text:
        "What is the most expensive thing you broke and hid from your parents?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Who is your favorite sibling/cousin? (Be honest!)",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "What was the worst gift you ever received from a family member?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "If you could change one thing about our house, what would it be?",
    type: TruthOrDareChoice.truth,
    category: TruthDareCategory.family,
  ),
];

const List<TruthDareQuestion> familyDares = [
  TruthDareQuestion(
    text: "Give a sincere compliment to every person playing.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Do a funny walk from one end of the room to the other.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Act out a scene from your favorite movie with someone else.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Let someone else control the music for the next 3 songs.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Imitate a family member (without being disrespectful).",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Do a plank for 45 seconds while answering questions.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text:
        "Let the group compose a WhatsApp status for you and keep it up for 10 minutes.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Talk without closing your mouth for the next two rounds.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Call a pizza place (or any store) and ask if they sell tires.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Let someone draw a mustache on your face with a pen (or makeup).",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.friends,
  ),
  TruthDareQuestion(
    text: "Talk like a news anchor for the next 2 minutes.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text:
        "Tell the group a dad joke. If no one laughs, you have to do another dare.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Show the group the oldest photo you have on your phone.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
  TruthDareQuestion(
    text: "Let the youngest person in the room draw something on your hand.",
    type: TruthOrDareChoice.dare,
    category: TruthDareCategory.family,
  ),
];

class FamilyPack {
  static List<TruthDareQuestion> getTruths() => familyTruths;
  static List<TruthDareQuestion> getDares() => familyDares;
}
