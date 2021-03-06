import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:muse_player/muse_player.dart';
import 'package:netease_cloud_music/netease_cloud_music.dart' as api;
import 'package:overlay_support/overlay_support.dart';
import 'package:muse/component/route.dart';
import 'package:muse/material/app.dart';
import 'package:muse/pages/account/account.dart';
import 'package:muse/pages/splash/page_splash.dart';
import 'package:muse/repository/netease.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'component/global/settings.dart';
import 'component/netease/netease.dart';
import 'component/player/interceptors.dart';
import 'component/player/player.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  WidgetsFlutterBinding.ensureInitialized();
  neteaseRepository = NeteaseRepository();
  api.debugPrint = debugPrint;
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(PageSplash(
    futures: [
      SharedPreferences.getInstance(),
      UserAccount.getPersistenceUser(),
      getApplicationDocumentsDirectory().then((dir) {
        Hive.init(dir.path);
        return Hive.openBox<Map>("player");
      }),
    ],
    builder: (context, data) {
      return MyApp(
        setting: Settings(data[0]),
        user: data[1],
        player: data[2],
      );
    },
  ));
}

/// The entry of dart background service
/// NOTE: this method will be invoked by native (Android/iOS)
@pragma('vm:entry-point') // avoid Tree Shaking
void playerBackgroundService() {
  WidgetsFlutterBinding.ensureInitialized();
  // 获取播放地址需要使用云音乐 API, 所以需要为此 isolate 初始化一个 repository.
  neteaseRepository = NeteaseRepository();
  runBackgroundService(
    imageLoadInterceptor: BackgroundInterceptors.loadImageInterceptor,
    playUriInterceptor: BackgroundInterceptors.playUriInterceptor,
    playQueueInterceptor: QuietPlayQueueInterceptor(),
  );
}

class MyApp extends StatelessWidget {
  final Settings setting;

  final Map user;

  final Box<Map> player;

  const MyApp({Key key, @required this.setting, @required this.user, this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Settings>(
      model: setting,
      child: ScopedModelDescendant<Settings>(builder: (context, child, setting) {
        return Netease(
          user: user,
          child: Quiet(
            box: player,
            child: OverlaySupport(
              child: MaterialApp(
                routes: routes,
                onGenerateRoute: routeFactory,
                title: 'Muse',
                theme: setting.theme,
                darkTheme: setting.darkTheme,
                themeMode: setting.themeMode,
                initialRoute: getInitialRoute(),
              ),
            ),
          ),
        );
      }),
    );
  }

  String getInitialRoute() {
    bool login = user != null;
    if (!login && !setting.skipWelcomePage) {
      return pageWelcome;
    }
    return pageMain;
  }
}
