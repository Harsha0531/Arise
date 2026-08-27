enum Rank {
  unawakened,
  f,
  e,
  d,
  c,
  b,
  a,
  s,
  ss,
  sss,
}

extension RankInfo on Rank {
  String get code {
    switch (this) {
      case Rank.unawakened:
        return 'UNAWAKENED';
      case Rank.f:
        return 'F';
      case Rank.e:
        return 'E';
      case Rank.d:
        return 'D';
      case Rank.c:
        return 'C';
      case Rank.b:
        return 'B';
      case Rank.a:
        return 'A';
      case Rank.s:
        return 'S';
      case Rank.ss:
        return 'SS';
      case Rank.sss:
        return 'SSS';
    }
  }

  String get title {
    switch (this) {
      case Rank.unawakened:
        return 'Dormant';
      case Rank.f:
        return 'Awakened';
      case Rank.e:
        return 'Hunter';
      case Rank.d:
        return 'Warlord';
      case Rank.c:
        return 'Knight';
      case Rank.b:
        return 'Commander';
      case Rank.a:
        return 'Sovereign';
      case Rank.s:
        return 'Supreme';
      case Rank.ss:
        return 'Overlord';
      case Rank.sss:
        return 'Emperor';
    }
  }

  int get levelCount {
    switch (this) {
      case Rank.unawakened:
        return 5;
      case Rank.f:
        return 10;
      case Rank.e:
        return 10;
      case Rank.d:
        return 15;
      case Rank.c:
        return 20;
      case Rank.b:
        return 25;
      case Rank.a:
        return 30;
      case Rank.s:
        return 40;
      case Rank.ss:
        return 50;
      case Rank.sss:
        return 100;
    }
  }

  double get xpMultiplier {
    switch (this) {
      case Rank.unawakened:
        return 1.0;
      case Rank.f:
        return 1.2;
      case Rank.e:
        return 1.5;
      case Rank.d:
        return 2.0;
      case Rank.c:
        return 3.0;
      case Rank.b:
        return 5.0;
      case Rank.a:
        return 8.0;
      case Rank.s:
        return 15.0;
      case Rank.ss:
        return 30.0;
      case Rank.sss:
        return 60.0;
    }
  }
}