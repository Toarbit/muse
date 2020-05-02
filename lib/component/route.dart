import 'package:flutter/material.dart';
import 'package:muse/pages/collection/page_collections.dart';
import 'package:muse/pages/leaderboard/page_leaderboard.dart';
import 'package:muse/pages/main/page_main.dart';
import 'package:muse/pages/page_my_dj.dart';
import 'package:muse/pages/player/page_fm_playing.dart';
import 'package:muse/pages/player/page_playing.dart';
import 'package:muse/pages/playlist/page_daily_playlist.dart';
import 'package:muse/pages/playlist/page_personalized_playlist.dart';
import 'package:muse/pages/playlist/page_top_playlist.dart';
import 'package:muse/pages/setting/page_setting.dart';
import 'package:muse/pages/video/page_music_video_player.dart';
import 'package:muse/pages/welcome/login_sub_navigation.dart';
import 'package:muse/pages/welcome/page_welcome.dart';

export 'package:muse/pages/collection/page_collections.dart';
export 'package:muse/pages/leaderboard/page_leaderboard.dart';
export 'package:muse/pages/main/page_main.dart';
export 'package:muse/pages/player/page_playing.dart';
export 'package:muse/pages/playlist/page_album_detail.dart';
export 'package:muse/pages/playlist/page_daily_playlist.dart';
export 'package:muse/pages/playlist/page_playlist_detail.dart';
export 'package:muse/pages/setting/page_setting.dart';
export 'package:muse/pages/video/page_music_video_player.dart';

const pageMain = Navigator.defaultRouteName;

///popup with [true] if login succeed
const pageLogin = "/login";

const ROUTE_PLAYLIST_DETAIL = "/playlist/detail";

/// Route name of [PlayingPage].
const pagePlaying = "/playing";

/// 私人FM
const pageFmPlaying = "/playing_fm";

const pageLeaderboard = "/leaderboard";

/// Route name of [DailyPlaylistPage]
const pageDaily = "/daily";

const pageMyDj = '/mydj';

const ROUTE_MY_COLLECTION = '/my_collection';

const ROUTE_SETTING = '/setting';

const ROUTE_SETTING_THEME = '/setting/theme';

const ROUTE_TOP_PLAYLIST = "/toplist";

const ROUTE_PERSONALIZED_PLAYLIST = "/personalized_list";

const pageWelcome = 'welcome';

/// Search page route name
const pageSearch = "search";

///app routers
final Map<String, WidgetBuilder> routes = {
  pageMain: (context) => MainPage(),
  pageLogin: (context) => LoginNavigator(),
  pagePlaying: (context) => PlayingPage(),
  pageLeaderboard: (context) => LeaderboardPage(),
  pageDaily: (context) => DailyPlaylistPage(),
  pageMyDj: (context) => MyDjPage(),
  ROUTE_MY_COLLECTION: (context) => MyCollectionPage(),
  ROUTE_SETTING: (context) => SettingPage(),
  ROUTE_SETTING_THEME: (context) => SettingThemePage(),
  ROUTE_TOP_PLAYLIST: (context) => TopPlaylistPage(),
  ROUTE_PERSONALIZED_PLAYLIST: (context) => PersonalizedPlaylistPage(),
  pageWelcome: (context) => PageWelcome(),
  pageFmPlaying: (context) => PagePlayingFm(),
};

Route<dynamic> routeFactory(RouteSettings settings) {
  WidgetBuilder builder;
  switch (settings.name) {
    case "/mv":
      builder = (context) => MusicVideoPlayerPage(settings.arguments);
      break;
  }

  if (builder != null) return MaterialPageRoute(builder: builder, settings: settings);

  assert(false, 'ERROR: can not generate Route for ${settings.name}');
  return null;
}
