import 'package:dio/dio.dart';

import '../constants/split_patterns.dart';
import '../models/league_model.dart';
import '../models/match_model.dart';

class ApiScraper {
  final String _startUrl = "https://777score.com/";
  final Dio _dio = Dio();

  Future<String> _apiData() async {
    final response = await _dio.get(_startUrl);
    if (response.statusCode == 200) {
      return "${response.data}";
    }
    return "";
  }

  List<String> _forMakeLeague(String apiData) {
    List<String> splitedData = [];
    String last = "";
    splitedData.addAll(apiData.split(Patterns.forLeagues));
    splitedData.removeAt(0);
    last = splitedData.last;
    splitedData.removeLast();
    String result = last.split(Patterns.forLeaguesLast).first;
    splitedData.add(result);
    return splitedData;
  }

  String _getLeagueLogo(String apiData) {
    String second = apiData.split(Patterns.forLeagueLogo)[1];
    String url0 = second.split('''" width="20"''').first;
    String url = url0.replaceFirst("/50/50/", "/200/200/");
    return url;
  }

  String _getLeagueName(String apiData) {
    String _country = apiData.split('''"country-name">''')[1];
    String _countryName = _country.split('''</span>''').first;
    String _forLeagueName = _country.split('''</span>''')[1];
    String _league = _forLeagueName.split('''</a>''').first.trim();
    return "$_countryName: $_league";
  }

  MatchModel _scrapeMatch(String chapter) {
    String htmlData = chapter;
    var matchTime = _extractText(htmlData, '<span class="data">', '</span>');
    var matchStatus =
        _extractText(htmlData, '<span class="status">', '</span>');
    var teamHost = _extractText(
        htmlData, '<span class="name ellipsis">', '</span>',
        index: 0);
    var teamGuest = _extractText(
        htmlData, '<span class="name ellipsis">', '</span>',
        index: 1);
    var scoreHost =
        _extractText(htmlData, '<span class="point scoreHost">', '</span>');
    var scoreGuest =
        _extractText(htmlData, '<span class="point scoreGuest">', '</span>');
    var imgHostUrl = _extractAttribute(htmlData, '<img', 'data-lazy-img');
    var imgGuestUrl =
        _extractAttribute(htmlData, '<img', 'data-lazy-img', index: 1);
    imgGuestUrl = imgGuestUrl.replaceFirst('/50/50/', '/200/200/');
    imgHostUrl = imgHostUrl.replaceFirst("/50/50/", "/200/200/");

    return MatchModel(
      leagueName: "",
      leagueLogo: "",
      homeTeam: teamHost,
      awayTeam: teamGuest,
      awayLogo: imgGuestUrl,
      awayScore: scoreGuest,
      homeLogo: imgHostUrl,
      homeScore: scoreHost,
      live: matchStatus,
      time: matchTime,
    );
  }

  String _extractText(String input, String startTag, String endTag,
      {int index = 0}) {
    RegExp regex = RegExp('$startTag(.*?)$endTag');
    var match = regex.allMatches(input).elementAt(index);
    return match.group(1)?.trim() ?? '';
  }

  String _extractAttribute(
      String input, String elementTag, String attributeName,
      {int index = 0}) {
    RegExp regex = RegExp('$elementTag[\\s\\S]*?$attributeName="(.*?)"');
    var match = regex.allMatches(input).elementAt(index);
    return match.group(1)?.trim() ?? '';
  }

  List<String> _forLeagueMatch(String string) {
    List<String> result = [];
    result = string.split('''<span class="font-1rem">''');
    result.removeAt(0);
    return result;
  }

  Future<void> runScraping() async {
    print('starting...');
    List<LeagueModel> leagues = [];
    final apiData = await _apiData();
    for (final data in _forMakeLeague(apiData)) {
      List<MatchModel> matches = [];
      final leagueName = _getLeagueName(data);
      final leagueLogo = _getLeagueLogo(data);
      for (final match in _forLeagueMatch(data)) {
        MatchModel matchModel = _scrapeMatch(match);
        matchModel.leagueLogo = leagueLogo;
        matchModel.leagueName = leagueName;
        matches.add(matchModel);
      }
      LeagueModel leagueModel = LeagueModel(
        leagueName: leagueName,
        leagueLogo: leagueLogo,
        matches: matches,
      );
      leagues.add(leagueModel);
    }

    print("Completed: "+"${leagues.length} leagues have!");
  }
}
