// lib/games/most_likely/most_likely_packs.dart
import 'most_likely_models.dart';

/// Central place for all "Who's Most Likely To" prompts.
/// You can extend these lists whenever you want.
class MostLikelyPacks {
  static List<String> getQuestions(MostLikelyPack pack) {
    switch (pack) {
      case MostLikelyPack.clean:
        return [
          "Most likely to become rich?",
          "Most likely to forget their own birthday?",
          "Most likely to arrive late to their own wedding?",
          "Most likely to win a lottery?",
          "Most likely to become famous?",
          "Most likely to adopt 10 dogs?",
          "Most likely to sleep through an alarm?",
          "Most likely to laugh at the wrong moment?",
          "Most likely to binge-watch a whole series in one day?",
          "Most likely to cry during a movie?",
          "Most likely to organize a surprise party?",
          "Most likely to volunteer for everything?",
          "Most likely to become a school principal?",
          "Most likely to start a charity?",
          "Most likely to forget where they parked?",
        ];

      case MostLikelyPack.savage:
        return [
          "Most likely to ghost someone?",
          "Most likely to leave a message on 'read'?",
          "Most likely to forget to pay someone back?",
          "Most likely to start a fight in a group chat?",
          "Most likely to talk behind someone's back?",
          "Most likely to create drama for no reason?",
          "Most likely to be late and still act offended?",
          "Most likely to eat your food without asking?",
          "Most likely to forget your birthday?",
          "Most likely to lie about 'I'm on my way'?",
          "Most likely to stalk their ex online?",
          "Most likely to overshare secrets?",
          "Most likely to rage quit a game?",
          "Most likely to blame others for their mistake?",
          "Most likely to fake being sick to skip plans?",
        ];

      case MostLikelyPack.adult:
        // 🔞 THESE ARE ONLY ACCESSIBLE WHEN AppSettings.adultEnabled == true
        return [
          "Most likely to hook up at a party?",
          "Most likely to kiss someone on the first date?",
          "Most likely to text their ex at 3 AM?",
          "Most likely to have a one night stand?",
          "Most likely to flirt with the bartender?",
          "Most likely to go on a blind date?",
          "Most likely to fall for a friend with benefits?",
          "Most likely to use a dating app daily?",
          "Most likely to send a risky DM?",
          "Most likely to forget someone's name after kissing them?",
          "Most likely to end up in a love triangle?",
          "Most likely to date two people at the same time?",
          "Most likely to flirt with their friend's crush?",
          "Most likely to get back with an ex?",
          "Most likely to lie about their relationship status?",
        ];

      case MostLikelyPack.smart:
        return [
          "Most likely to start a startup?",
          "Most likely to become a billionaire?",
          "Most likely to invent something useful?",
          "Most likely to study for fun?",
          "Most likely to become a professor?",
          "Most likely to learn a new language randomly?",
          "Most likely to read a book instead of partying?",
          "Most likely to solve a Rubik's cube fast?",
          "Most likely to win a quiz competition?",
          "Most likely to get a scholarship?",
          "Most likely to build an app?",
          "Most likely to give a TED talk?",
          "Most likely to become a scientist?",
          "Most likely to argue using statistics?",
          "Most likely to correct other people's grammar?",
        ];

      case MostLikelyPack.stupidFun:
        return [
          "Most likely to trip on a flat road?",
          "Most likely to walk into a glass door?",
          "Most likely to laugh in a serious situation?",
          "Most likely to forget why they walked into a room?",
          "Most likely to fall off a chair?",
          "Most likely to send a message to the wrong chat?",
          "Most likely to start dancing with no music?",
          "Most likely to choke on water while doing nothing?",
          "Most likely to wear clothes inside out?",
          "Most likely to say 'you too' to a waiter?",
          "Most likely to forget their phone password?",
          "Most likely to sit on a remote and blame others?",
          "Most likely to trip in public and pretend it was intentional?",
          "Most likely to forget what day it is?",
          "Most likely to say 'present' during online class with mic off?",
        ];
    }
  }

  /// Combine questions from multiple packs.
  /// You can shuffle this in the game screen.
  static List<String> buildQuestionPool(List<MostLikelyPack> packs) {
    final pool = <String>[];
    for (final pack in packs) {
      pool.addAll(getQuestions(pack));
    }
    // Deduplicate just in case
    return pool.toSet().toList();
  }
}
