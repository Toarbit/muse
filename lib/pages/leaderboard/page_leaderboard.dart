import 'package:flutter/material.dart';
import 'package:muse/pages/playlist/page_playlist_detail.dart';
import 'package:muse/part/part.dart';
import 'package:muse/repository/netease.dart';

///各个排行榜数据
class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("排行榜"),
      ),
      body: Loader<Map>(
        loadTask: () => neteaseRepository.topListDetail(),
        builder: (context, result) {
          return _Leaderboard((result['list'] as List).cast());
        },
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  _Leaderboard(this.data);

  final List<Map> data;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(_ItemTitle("官方榜"));
    for (var i = 0; i < 4; i++) {
      widgets.add(_ItemLeaderboard1(data[i]));
    }
    widgets.add(_ItemTitle("全球榜"));
    widgets.add(GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8),
        shrinkWrap: true,
        itemCount: data.length - 4,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 10 / 13.5, mainAxisSpacing: 4, crossAxisSpacing: 8),
        itemBuilder: (context, int i) {
          return _ItemLeaderBoard2(data[i + 4]);
        }));
    return ListView(
      children: widgets,
    );
  }
}

class _ItemTitle extends StatelessWidget {
  _ItemTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 16, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ItemLeaderBoard2 extends StatelessWidget {
  _ItemLeaderBoard2(this.row);

  final Map row;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(row["id"]);
        }));
      },
      child: Container(
        height: 130,
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: <Widget>[
                    Image(image: CachedImage(row["coverImgUrl"])),
//                    Align(
//                      alignment: Alignment.bottomCenter,
//                      child: Container(
//                        height: 24,
//                        width: double.infinity,
//                        decoration: BoxDecoration(
//                            gradient: LinearGradient(
//                                begin: Alignment.topCenter,
//                                end: Alignment.bottomCenter,
//                                colors: const [
//                              Colors.transparent,
//                              Colors.black45
//                            ])),
//                        child: Row(
//                          children: <Widget>[
//                            Spacer(),
//                            Text(
//                              row["updateFrequency"],
//                              style: Theme.of(context).primaryTextTheme.caption,
//                            ),
//                            Padding(padding: EdgeInsets.only(right: 4))
//                          ],
//                        ),
//                      ),
//                    )
                  ],
                ),
              ),
            ),
            Text(
              row["name"],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemLeaderboard1 extends StatelessWidget {
  _ItemLeaderboard1(this.row);

  final Map row;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(row["id"]);
        }));
      },
      child: Container(
        height: 130,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: <Widget>[
                    Image(image: CachedImage(row["coverImgUrl"])),
//                    Align(
//                      alignment: Alignment.bottomCenter,
//                      child: Container(
//                        height: 24,
//                        width: double.infinity,
//                        decoration: BoxDecoration(
//                            gradient: LinearGradient(
//                                begin: Alignment.topCenter,
//                                end: Alignment.bottomCenter,
//                                colors: const [
//                              Colors.transparent,
//                              Colors.black45
//                            ])),
//                        child: Row(
//                          children: <Widget>[
//                            Spacer(),
//                            Text(
//                              row["updateFrequency"],
//                              style: Theme.of(context).primaryTextTheme.caption,
//                            ),
//                            Padding(padding: EdgeInsets.only(right: 4))
//                          ],
//                        ),
//                      ),
//                    )
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(left: 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  _getTrackItem((row["tracks"] as List)[0] as Map, context),
                  Spacer(),
                  _getTrackItem((row["tracks"] as List)[1] as Map, context),
                  Spacer(),
                  _getTrackItem((row["tracks"] as List)[2] as Map, context),
                  Spacer(),
                  Divider(
                    height: 0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getTrack(Map map) {
    return "${map["first"]} - ${map["second"]}";
  }
  Widget _getTrackItem(Map map, context) {
    return RichText(
      text: TextSpan(
          children: <TextSpan> [
            TextSpan(text: map["first"], style: Theme.of(context).textTheme.subtitle),
            TextSpan(text: " - ${map["second"]}", style: Theme.of(context).textTheme.caption)
          ]
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
