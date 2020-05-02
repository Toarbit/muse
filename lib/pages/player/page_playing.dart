import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:muse/component/netease/netease.dart';
import 'package:muse/material.dart';
import 'package:muse/material/player.dart';
import 'package:muse/pages/artists/page_artist_detail.dart';
import 'package:muse/pages/comments/page_comment.dart';
import 'package:muse/pages/page_playing_list.dart';
import 'package:muse/pages/player/page_playing_landscape.dart';
import 'package:muse/part/part.dart';
import 'package:muse_player/muse_player.dart';

import 'background.dart';
import 'cover.dart';
import 'lyric.dart';
import 'player_progress.dart';

///歌曲播放页面
class PlayingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context.listenPlayerValue.current;
    if (current == null) {
      WidgetsBinding.instance.scheduleFrameCallback((_) {
        Navigator.of(context).pop();
      });
      return Container();
    }
    if (context.isLandscape) {
      return LandscapePlayingPage();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          BlurBackground(music: current),
          Material(
            color: Colors.transparent,
            child: Column(
              children: <Widget>[
                _PlayingSimpleTitle(),
                _CenterSection(music: current),
                DurationProgressBar(),
                PlayerControllerBar(),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///player controller
/// pause,play,play next,play previous...
class PlayerControllerBar extends StatelessWidget {
  Widget getPlayModeIcon(BuildContext context, Color color) {
    return Icon(context.playMode.icon, color: color);
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryIconTheme.color;

    final iconPlayPause = PlayingIndicator(
      playing: IconButton(
          tooltip: "暂停",
          iconSize: 40,
          icon: Icon(
            Icons.pause,
            color: color,
          ),
          onPressed: () {
            context.transportControls.pause();
          }),
      pausing: IconButton(
          tooltip: "播放",
          iconSize: 40,
          icon: Icon(
            Icons.play_arrow,
            color: color,
          ),
          onPressed: () {
            context.transportControls.play();
          }),
      buffering: Container(
        height: 56,
        width: 56,
        child: Center(
          child: Container(height: 24, width: 24, child: CircularProgressIndicator()),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_previous,
                color: color,
              ),
              onPressed: () {
                context.transportControls.skipToPrevious();
              }),
          iconPlayPause,
          IconButton(
              tooltip: "下一曲",
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
                color: color,
              ),
              onPressed: () {
                context.transportControls.skipToNext();
              }),
          IconButton(
              tooltip: "当前播放列表",
              icon: Icon(
                Icons.list,
                color: color,
              ),
              onPressed: () {
                PlayingListDialog.show(context);
              }),
        ],
      ),
    );
  }
}

class PlayingOperationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).primaryIconTheme.color;

    final music = context.listenPlayerValue.current;
    final liked = LikedSongList.contain(context, music);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: iconColor,
            ),
            onPressed: () {
              if (liked) {
                LikedSongList.of(context).dislikeMusic(music);
              } else {
                LikedSongList.of(context).likeMusic(music);
              }
            }),
//        IconButton(
//            icon: Icon(
//              Icons.file_download,
//              color: iconColor,
//            ),
//            onPressed: () {
//              notImplemented(context);
//            }),
        IconButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
            ),
            onPressed: () {
              if (music == null) {
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CommentPage(
                  threadId: CommentThreadId(music.id, CommentType.song, payload: CommentThreadPayload.music(music)),
                );
              }));
            }),
//        IconButton(
//            icon: Icon(
//              Icons.share,
//              color: iconColor,
//            ),
//            onPressed: () {
//              notImplemented(context);
//            }),
      ],
    );
  }
}

class _CenterSection extends StatefulWidget {
  final Music music;

  const _CenterSection({Key key, @required this.music}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CenterSectionState();
}

class _CenterSectionState extends State<_CenterSection> {
  static bool _showLyric = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedCrossFade(
        crossFadeState: _showLyric ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        layoutBuilder: (Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
          return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Center(
                key: bottomChildKey,
                child: bottomChild,
              ),
              Center(
                key: topChildKey,
                child: topChild,
              ),
            ],
          );
        },
        duration: Duration(milliseconds: 300),
        firstChild: GestureDetector(
          onTap: () {
            setState(() {
              _showLyric = !_showLyric;
            });
          },
          child: Column(
            children: <Widget>[
              StaticAlbumCover(music: widget.music),
              _PlayingInfo(music: widget.music),
            ],
          )
        ),
        secondChild: PlayingLyricView(
          music: widget.music,
          onTap: () {
            setState(() {
              _showLyric = !_showLyric;
            });
          },
        ),
      ),
    );
  }
}

class PlayingLyricView extends StatelessWidget {
  final VoidCallback onTap;

  final Music music;

  const PlayingLyricView({Key key, this.onTap, @required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProgressTrackingContainer(builder: _buildLyric, player: context.player);
  }

  Widget _buildLyric(BuildContext context) {
    TextStyle style = Theme.of(context).textTheme.bodyText2.copyWith(height: 2, fontSize: 20, color: Colors.white);
    final playingLyric = PlayingLyric.of(context);

    if (playingLyric.hasLyric) {
      return LayoutBuilder(builder: (context, constraints) {
        final normalStyle = style.copyWith(color: style.color.withOpacity(0.5));
        //歌词顶部与尾部半透明显示
        return ShaderMask(
          shaderCallback: (rect) {
            return ui.Gradient.linear(Offset(rect.width / 2, 0), Offset(rect.width / 2, constraints.maxHeight), [
              const Color(0x00FFFFFF),
              style.color,
              style.color,
              const Color(0x00FFFFFF),
            ], [
              0.0,
              0.15,
              0.85,
              1
            ]);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Lyric(
              lyric: playingLyric.lyric,
              lyricLineStyle: normalStyle,
              highlight: style.color,
              position: context.playbackState.positionWithOffset,
              onTap: onTap,
              size: Size(constraints.maxWidth, constraints.maxHeight == double.infinity ? 0 : constraints.maxHeight),
              playing: context.playbackState.isPlaying,
            ),
          ),
        );
      });
    } else {
      return Container(
        child: Center(
          child: Text(playingLyric.message, style: style),
        ),
      );
    }
  }
}

class PlayingTitle extends StatelessWidget {
  final Music music;

  const PlayingTitle({Key key, @required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: AppBar(
        elevation: 0,
        primary: false,
        leading: LandscapeWidgetSwitcher(
          portrait: (context) {
            return IconButton(
                tooltip: '返回上一层',
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
                onPressed: () => Navigator.pop(context));
          },
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              music.title,
              style: TextStyle(fontSize: 17),
            ),
            InkWell(
              onTap: () {
                launchArtistDetailPage(context, music.artist);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: Text(
                      music.artistString,
                      style: Theme.of(context).primaryTextTheme.bodyText2.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 17),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text("下载"),
                ),
              ];
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
          ),
          LandscapeWidgetSwitcher(landscape: (context) {
            return CloseButton(onPressed: () {
              context.rootNavigator.maybePop();
            });
          })
        ],
      ),
    );
  }
}

class _PlayingSimpleTitle extends StatelessWidget {

  const _PlayingSimpleTitle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: AppBar(
        elevation: 0,
        primary: false,
        leading: IconButton(
            tooltip: '返回上一层',
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: "download",
                  child: ListTile(leading: Icon(Icons.file_download), title: Text("下载"))
                ),
                PopupMenuItem<String>(
                    value: "comment",
                    child: ListTile(leading: Icon(Icons.comment), title: Text("评论"))
                ),
              ];
            },
            onSelected: (String action) {
              switch (action) {
                case "comment":
                  final music = context.listenPlayerValue.current;
                  if (music == null) {
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CommentPage(
                      threadId: CommentThreadId(music.id, CommentType.song, payload: CommentThreadPayload.music(music)),
                    );
                  }));
                  break;
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
          )
        ],
      ),
    );
  }
}

class _PlayingInfo extends StatelessWidget {

  final Music music;

  const _PlayingInfo({Key key, @required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final music = context.listenPlayerValue.current;
    final liked = LikedSongList.contain(context, music);
    final theme = Theme.of(context).primaryTextTheme;

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 36),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        music.title,
                        style: theme.headline5.copyWith(color: theme.bodyText2.color.withOpacity(0.85)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      )
                  ),
                  Text(
                    music.artist.map((a) => a.name).join('/'),
                    style: theme.headline6.copyWith(color: theme.bodyText2.color.withOpacity(0.65)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
                iconSize: 32,
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: Theme.of(context).primaryIconTheme.color.withOpacity(0.7),
                ),
                onPressed: () {
                  if (liked) {
                    LikedSongList.of(context).dislikeMusic(music);
                  } else {
                    LikedSongList.of(context).likeMusic(music);
                  }
                }),
          ],
        )
    );
  }
}
