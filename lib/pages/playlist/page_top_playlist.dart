import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loader/loader.dart';
import 'package:muse/model/playlist_detail.dart';
import 'package:muse/pages/playlist/page_playlist_detail.dart';
import 'package:muse/repository/netease.dart';

class TopPlaylistPage extends StatefulWidget {
  @override
  createState() => _TopPlaylistState();
}

class _TopPlaylistState extends State<TopPlaylistPage> {
  List<Map> data;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMore();
      }
    });
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("热门歌单"),
      ),
      body: view(context)
    );
  }

  Widget view(BuildContext context) {
    if (data == null)
      return Loader<Map>(
        loadTask: () => neteaseRepository.topPlaylist(),
        builder: (context, result) {
          data = (result["playlists"] as List).cast();
          return buildView(context);
        },
      );
    return buildView(context);
  }
  Widget buildView(BuildContext context) {
    return RefreshIndicator(
      child: data == null ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        controller: _scrollController,
        child: GridView.count(
          padding: EdgeInsets.all(6.0),
          physics: NeverScrollableScrollPhysics(),
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
    var list = await (await neteaseRepository.topPlaylist()).asFuture;
//    debugPrint("load refresh size: ${list.length}");
    setState(() {
      data = (list["playlists"] as List).cast();
//      debugPrint("load refresh end, totally: ${data.length}");
    });
  }

  // TODO 提供加载标识
  Future<Null> _getMore() async {
    var list = await (await neteaseRepository.topPlaylist(offset: data.length)).asFuture;
//    debugPrint("load more size: ${list.length}");
    setState(() {
      data.addAll((list["playlists"] as List).cast());
//      debugPrint("load more end, totally: ${data.length}");
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
            playlist["id"], playlist: PlaylistDetail.fromMap(playlist),
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
              style: Theme.of(context).textTheme.subtitle.copyWith(height: 0.97),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
