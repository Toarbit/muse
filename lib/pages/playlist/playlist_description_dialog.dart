import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:muse/material/button.dart' as button;
import 'package:muse/model/playlist_detail.dart';
import 'package:muse/repository/cached_image.dart';

class PlayListDescDialog extends StatelessWidget {
  final PlaylistDetail playlist;

  PlayListDescDialog(this.playlist);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: <Widget>[
          Image(fit: BoxFit.cover, image: CachedImage(playlist.coverUrl)),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaY: 24,
              sigmaX: 24,
            ),
            child: Container(
              color: Colors.black54,
            ),
          ),
          Stack(
            children: <Widget>[
              Positioned.fill(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: Column(
                        children: <Widget>[
                          Padding(padding: EdgeInsets.symmetric(vertical: 32)),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Hero(
                              tag: playlist.heroTag,
                              child: Image(
                                  fit: BoxFit.cover,
                                  image: CachedImage(playlist.coverUrl),
                                  width: 240,
                                  height: 240),
                            ),
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 12)),
                          Text(
                            playlist.name,
                            style: Theme.of(context).primaryTextTheme.headline5,
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 16)),
                          Text(
                            playlist.description,
                            style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(color: Theme.of(context).primaryTextTheme.subtitle1.color.withOpacity(0.7)),
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 16)),
                        ],
                      )
                  )
              ),
              Positioned(
                left: 12,
                top: 12,
                child: SafeArea(
                    child: button.FrostedCloseButton(() {
                      Navigator.of(context).pop();
                    })),
              )
            ],
          )
        ],
      ),
    );
  }
}
