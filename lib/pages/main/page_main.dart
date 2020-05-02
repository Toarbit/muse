import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:muse/component/global/orientation.dart';
import 'package:muse/pages/account/page_user_detail.dart';
import 'package:muse/pages/main/main_cloud.dart';
import 'package:muse/pages/main/main_playlist.dart';
import 'package:muse/pages/search/page_search.dart';
import 'package:muse/part/part.dart';
import 'package:muse/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

part 'drawer.dart';
part 'page_main_landscape.dart';
part 'page_main_portrait.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return context.isLandscape ? _LandscapeMainPage() : _PortraitMainPage();
  }
}

extension LandscapeMainContext on BuildContext {
  /// Obtain the primary navigator for landscape mode.
  NavigatorState get landscapePrimaryNavigator =>
      findAncestorStateOfType<_LandscapeMainPageState>()._landscapeNavigatorKey.currentState;

  /// Obtain the secondary navigator for landscape mode.
  NavigatorState get landscapeSecondaryNavigator =>
      findAncestorStateOfType<_LandscapeMainPageState>()._landscapeSecondaryNavigatorKey.currentState;
}
