part of 'comments.dart';

class _ItemTitle extends StatelessWidget {
  const _ItemTitle({Key key, @required this.commentThreadId})
      : assert(commentThreadId != null),
        super(key: key);

  final CommentThreadId commentThreadId;

  CommentThreadPayload get payload => commentThreadId.payload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () async {
            if (commentThreadId.type == CommentType.playlist) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                final playlist = (payload.obj as PlaylistDetail);
                return PlaylistDetailPage(
                  playlist.id,
                  playlist: playlist,
                );
              }));
            } else if (commentThreadId.type == CommentType.song) {
              Music music = payload.obj;
              if (context.playerValue.current != music) {
                dynamic result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text("开始播放 ${music.title} ?"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("取消")),
                          FlatButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text("播放")),
                        ],
                      );
                    });
                if (!(result is bool && result)) {
                  return;
                }
                context
                  ..player.insertToNext(music.metadata)
                  ..transportControls.playFromMediaId(music.metadata.mediaId);
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PlayingPage();
              }));
            }
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  child: Image(
                    fit: BoxFit.cover,
                    image: CachedImage(payload.coverImage),
                    width: 60,
                    height: 60,
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
                Expanded(
                  child: Container(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          payload.title,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        Text(
                          payload.subtitle,
                          style: Theme.of(context).textTheme.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right)
              ],
            ),
          ),
        ),
        Container(height: 7, color: Theme.of(context).dividerColor)
      ],
    );
  }
}

class _ItemLoadMore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: CircularProgressIndicator(),
            height: 16,
            width: 16,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8),
          ),
          Text("正在加载更多评论...")
        ],
      ),
    );
  }
}

class _ItemMoreHot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("go to hot comments");
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "全部精彩评论 >",
            style: Theme.of(context).textTheme.caption,
          ),
        ),
      ),
    );
  }
}

class _ItemHeader extends StatelessWidget {
  final String title;

  const _ItemHeader({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, top: 16, bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}

class _ItemComment extends StatefulWidget {
  const _ItemComment({Key key, @required this.comment}) : super(key: key);

  final Comment comment;

  @override
  _ItemCommentState createState() {
    return new _ItemCommentState();
  }
}

class _ItemCommentState extends State<_ItemComment> {

  Future<bool> onLikeButtonTapped(bool isLiked) async{
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;

    return !isLiked;
  }

  @override
  Widget build(BuildContext context) {
    User user = widget.comment.user;
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.only(),
                children: <Widget>[
                  ListTile(
                    title: Text("复制"),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.comment.content));
                      Navigator.pop(context);
                      toast('复制成功');
                    },
                  ),
                  Divider(
                    height: 0,
                  ),
                ],
              );
            });
      },
      child: DividerWrapper(
        indent: 60,
        child: Padding(
          padding: EdgeInsets.only(left: 16, top: 10, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                      child: InkResponse(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => UserDetailPage(userId: user.userId)));
                    },
                    child: Image(
                      image: CachedImage(user.avatarUrl),
                      width: 36,
                      height: 36,
                    ),
                  )),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        user.nickname,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      Text(
                        getFormattedTime(widget.comment.time),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  )),
                  LikeButton(
                      isLiked: widget.comment.liked,
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.thumb_up,
                          size: 16,
                          color: isLiked ? Theme.of(context).accentColor : Theme.of(context).disabledColor,
                        );
                      },
                      likeCount: widget.comment.likedCount,
                      countBuilder: (int count, bool isLiked, String text) =>
                        Text(
                          count < 10000 ? text : getFormattedNumber(count),
                          style: TextStyle(fontSize: 11, color: isLiked ? Theme.of(context).accentColor : Theme.of(context).disabledColor),
                        ),
                      /// [likeCountAnimationType] is link to [getFormattedNumber]
                      likeCountAnimationType: widget.comment.likedCount < 10000 ? LikeCountAnimationType.part : LikeCountAnimationType.none,
                      likeCountPadding: EdgeInsets.only(),
                      onTap: onLikeButtonTapped
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 44),
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Text(widget.comment.content, maxLines: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension KindCount on int {
  String toKindCount() {
    return _amountConversion(this);
  }

  static const double THOUSAND = 1000.0;
  static const double MILLION = 10000.0;
  static const String THOUSAND_UNIT = "千";
  static const String MILLION_UNIT = "万";

  String _amountConversion(num amount) {
    //最终返回的结果值
    String result = amount.toString();
    if (amount >= THOUSAND && amount < MILLION) {
      result = '${(amount / THOUSAND).toStringAsFixed(1)}$THOUSAND_UNIT';
    } else if (amount < MILLION * 10 && amount > MILLION) {
      result = '${(amount / MILLION).toStringAsFixed(1)}$MILLION_UNIT';
    } else if (amount >= MILLION * 10) {
      result = '${amount ~/ MILLION}$MILLION_UNIT';
    } else {
      result = amount.toString();
    }
    return result;
  }
}
