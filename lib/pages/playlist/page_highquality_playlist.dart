import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:muse/pages/playlist/page_playlist_detail.dart';
import 'package:muse/repository/netease.dart';

class HighQualityPlaylistPage extends StatefulWidget {
  @override
  createState() => _HighQualityPlaylistState();
}

class _HighQualityPlaylistState extends State<HighQualityPlaylistPage> {
  List<Map> data;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: const Text("精品歌单"),
        ),
        body: buildView(context)
    );
  }

  Widget buildView(BuildContext context) {
    return RefreshIndicator(
      child: data == null ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: GridView.count(
          padding: EdgeInsets.all(6.0),
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 10 / 12,
          children: data.map<Widget>((p) {
            return _buildPlaylistItem(context, p);
          }).toList(),
        ),
      ),
      onRefresh: () => _handleRefresh(),
    );
  }

  Future<Null> _handleRefresh() async {
    var list = await (await neteaseRepository.highQualityPlaylist()).asFuture;
    setState(() {
      data = (list["playlists"] as List).cast();
    });
  }

  Widget _buildPlaylistItem(BuildContext context, Map playlist) {
    GestureLongPressCallback onLongPress;

    String copyWrite = playlist["copywriter"];
    if (copyWrite != null && copyWrite.isNotEmpty) {
      onLongPress = () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                  playlist["copywriter"],
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            });
      };
    }

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PlaylistDetailPage(
            playlist["id"],
          );
        }));
      },
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 1,
                child: FadeInImage(
                  placeholder: AssetImage("assets/placeholder_album.png"),
                  image: CachedImage(playlist["coverImgUrl"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 8)),
            Text(
              playlist["name"],
              style: Theme.of(context).textTheme.subtitle2.copyWith(height: 0.97),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}