import 'dart:math';

enum HeadsUpPack {
  general,
  movies,
  desimovies,
  videoGames,
  anime,
  animals,
  food,
  superheroes,
  famousPeople,
  places,
  adult,
}

extension HeadsUpPackX on HeadsUpPack {
  String get label {
    switch (this) {
      case HeadsUpPack.general:
        return "General";
      case HeadsUpPack.movies:
        return "Movies";
      case HeadsUpPack.desimovies:
        return "Desi Movies";
      case HeadsUpPack.videoGames:
        return "Video Games";
      case HeadsUpPack.anime:
        return "Anime";
      case HeadsUpPack.animals:
        return "Animals";
      case HeadsUpPack.food:
        return "Food";
      case HeadsUpPack.superheroes:
        return "Superheroes";
      case HeadsUpPack.famousPeople:
        return "Famous People";
      case HeadsUpPack.places:
        return "Places";
      case HeadsUpPack.adult:
        return "Adult (18+)";
    }
  }

  List<String> get words {
    switch (this) {
      // ✅ GENERAL
      case HeadsUpPack.general:
        return [
          "Birthday",
          "Vacation",
          "Homework",
          "Airport",
          "Party",
          "Exam",
          "Laptop",
          "Headphones",
          "Rainy Day",
          "Gym",
          "Festival",
          "Shopping",
          "Swimming Pool",
          "Music",
          "Sleep",
          "Road Trip",
          "Wedding",
          "Library",
          "School Bus",
          "Doctor",
        ];

      // ✅ MOVIES
      case HeadsUpPack.movies:
        return [
          "Avengers",
          "Harry Potter",
          "Titanic",
          "Inception",
          "The Dark Knight",
          "Spider-Man",
          "Jurassic Park",
          "Fast & Furious",
          "Interstellar",
          "Deadpool",
          "Iron Man",
          "Avatar",
        ];
      case HeadsUpPack.desimovies:
        return [
          "3 Idiots",
          "Dangal",
          "Kabir Singh",
          "Bahubali",
          "PK",
          "Sultan",
          "Chennai Express",
          "Lagaan",
          "Zindagi Na Milegi Dobara",
          "Andaz Apna Apna",
          "Sholay",
          "Dilwale Dulhania Le Jayenge",
          "M.S. Dhoni",
          "RRR",
          "KGF",
          "Pushpa",
          "Baahubali",
          "Jawan",
          "Pathaan",
          "Animal",
        ];
      // ✅ VIDEO GAMES
      case HeadsUpPack.videoGames:
        return [
          "GTA V",
          "Minecraft",
          "PUBG",
          "Fortnite",
          "Valorant",
          "God of War",
          "Call of Duty",
          "FIFA",
          "Cricket 07",
          "League of Legends",
          "Clash of Clans",
          "Free Fire",
          "Among Us",
          "Elden Ring",
          "Cyberpunk",
        ];

      // ✅ ANIME
      case HeadsUpPack.anime:
        return [
          "Naruto",
          "Sasuke",
          "Luffy",
          "Zoro",
          "Goku",
          "One Punch Man",
          "Attack on Titan",
          "Demon Slayer",
          "Jujutsu Kaisen",
          "Death Note",
          "Tokyo Ghoul",
          "Dragon Ball Z",
          "Bleach",
          "Itachi",
          "Gojo",
        ];

      // ✅ ANIMALS
      case HeadsUpPack.animals:
        return [
          "Lion",
          "Tiger",
          "Elephant",
          "Panda",
          "Kangaroo",
          "Snake",
          "Eagle",
          "Dolphin",
          "Shark",
          "Penguin",
          "Horse",
          "Dog",
          "Cat",
          "Crocodile",
          "Wolf",
        ];

      // ✅ FOOD
      case HeadsUpPack.food:
        return [
          "Pizza",
          "Burger",
          "Pasta",
          "Sushi",
          "Ice Cream",
          "Biryani",
          "Dosa",
          "Vada Pav",
          "Tacos",
          "French Fries",
          "Noodles",
          "Pani Puri",
          "Chocolate",
          "Cake",
          "Sandwich",
        ];

      // ✅ SUPERHEROES
      case HeadsUpPack.superheroes:
        return [
          "Iron Man",
          "Captain America",
          "Thor",
          "Hulk",
          "Spider-Man",
          "Batman",
          "Superman",
          "Flash",
          "Wonder Woman",
          "Deadpool",
          "Black Panther",
          "Doctor Strange",
          "Ant-Man",
          "Aquaman",
        ];

      // ✅ FAMOUS PEOPLE
      case HeadsUpPack.famousPeople:
        return [
          "Elon Musk",
          "Virat Kohli",
          "MS Dhoni",
          "Ronaldo",
          "Messi",
          "Narendra Modi",
          "Bill Gates",
          "Steve Jobs",
          "Salman Khan",
          "Shah Rukh Khan",
          "Akshay Kumar",
          "Alia Bhatt",
          "Emma Watson",
          "Tom Cruise",
        ];

      // ✅ PLACES
      case HeadsUpPack.places:
        return [
          "India",
          "USA",
          "Dubai",
          "Paris",
          "London",
          "New York",
          "Mumbai",
          "Delhi",
          "Goa",
          "Maldives",
          "Japan",
          "China",
          "Italy",
          "Canada",
          "Singapore",
        ];

      // 🔞 ADULT (18+)
      case HeadsUpPack.adult:
        return [
          "Kiss",
          "Dating",
          "One Night Stand",
          "Breakup",
          "Hookup",
          "Crush",
          "Body Count",
          "Flirting",
          "Blind Date",
          "Ex",
          "Heartbreak",
          "Dirty Talk",
          "Friends with Benefits",
          "Cheating",
        ];
    }
  }
}

class HeadsUpConfig {
  final HeadsUpPack pack;
  final int durationSeconds;

  HeadsUpConfig({required this.pack, required this.durationSeconds});

  List<String> getShuffledWords() {
    final list = List<String>.from(pack.words);
    list.shuffle(Random());
    return list;
  }
}
