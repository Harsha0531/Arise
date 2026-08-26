import 'rank.dart';

class Player {
  String name;

  int level;
  int xp;
  int xpDebt;

  // Reward points earned from progression.
  // These remain unspent until the player assigns them.
  int rewardPoints;

  Rank rank;

  int strength;
  int intelligence;
  int vitality;
  int discipline;
  int focus;

  Player({
    this.name = 'Hunter',
    this.level = 1,
    this.xp = 0,
    this.xpDebt = 0,
    this.rewardPoints = 0,
    this.rank = Rank.unawakened,
    this.strength = 1,
    this.intelligence = 1,
    this.vitality = 1,
    this.discipline = 1,
    this.focus = 1,
  });
}