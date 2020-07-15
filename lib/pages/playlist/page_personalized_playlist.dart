import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:muse/pages/playlist/page_playlist_detail.dart';
import 'package:muse/repository/netease.dart';

class PersonalizedPlaylistPage extends StatefulWidget {
  @override
  createState() => _PersonalizedPlaylistState();
}


class _PersonalizedPlaylistState extends State<PersonalizedPlaylistPage> {
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
          title: const Text("推荐歌单"),
        ),
        body: buildView(context)
    );
  }

  Widget buildView(BuildContext context) {
    return RefreshIndicator(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: data == null ? CircularProgressIndicator() : GridView.count(
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
    var list = await (await neteaseRepository.personalizedPlaylist()).asFuture;
    setState(() {
      data = (list["result"] as List).cast();
    });
  }

  // TODO 提供加载标识
  Future<Null> _getMore() async {
    if (data == null || data.length == 0) return _handleRefresh();
    var list = await (await neteaseRepository.personalizedPlaylist(limit: data.length+30)).asFuture;
    setState(() {
      data.addAll((list["result"] as List).sublist(data.length+1).cast());
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
                  style: Theme.of(context).textTheme.body2,
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
                  image: CachedImage(playlist["picUrl"]),
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