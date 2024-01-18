class MatchModel {
  String leagueName;
  String leagueLogo;
  String time;
  String live;
  String homeTeam;
  String awayTeam;
  String homeLogo;
  String awayLogo;
  String homeScore;
  String awayScore;

  MatchModel({
    required this.leagueName,
    required this.leagueLogo,
    required this.homeTeam,
    required this.awayTeam,
    required this.awayLogo,
    required this.awayScore,
    required this.homeLogo,
    required this.homeScore,
    required this.live,
    required this.time,
  });
}
