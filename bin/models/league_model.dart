import 'match_model.dart';

class LeagueModel {
  String leagueName;
  String leagueLogo;
  List<MatchModel> matches;

  LeagueModel({
    required this.leagueName,
    required this.leagueLogo,
    required this.matches,
  });
}
