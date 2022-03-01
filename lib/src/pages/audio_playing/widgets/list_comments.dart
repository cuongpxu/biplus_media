import 'package:biplus_media/src/models/radio_comment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../api/biplus_media_api.dart';
import '../../../widgets/empty_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListComment extends StatefulWidget {
  const ListComment({Key? key, required this.mediaId}) : super(key: key);

  final int mediaId;

  @override
  _ListCommentState createState() => _ListCommentState();
}

class _ListCommentState extends State<ListComment> {
  bool _isLoading = false;
  bool _isLoadMore = true;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    _getListComment();
  }

  void _onRefresh() async {
    setState(() {
      comments.clear();
      _isLoading = !_isLoading;
      _isLoadMore = true;
      _onLoading();
    });
  }

  void _onLoading() async {
    if (_isLoadMore) {
      _getListComment();
      _refreshController.loadComplete();
    } else {
      setState(() {
        _refreshController.loadComplete();
        _isLoading = !_isLoading;
      });
    }
  }

  _getListComment() async {
    List<Comment> data = await BiplusMediaAPI()
        .getRadioComment(mediaId: widget.mediaId, offset: comments.length);
    if (comments.length < 20) {
      _isLoadMore = false;
    }
    setState(() {
      comments.addAll(data);
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          end: Alignment.topCenter,
          begin: Alignment.center,
          colors: [
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromLTRB(0, 0, rect.width, rect.height),
        );
      },
      blendMode: BlendMode.dstIn,
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: comments.isEmpty
                  ? emptyScreen(
                  context,
                  0,
                  ':( ',
                  50,
                  AppLocalizations.of(context)!.sorry,
                  30,
                  AppLocalizations.of(context)!.resultsNotFound,
                  10)
                  : SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  header: const WaterDropHeader(),
                  footer: CustomFooter(
                    builder: (context, mode) {
                      Widget body;
                      if (mode == LoadStatus.idle && _isLoadMore) {
                        body = const Text("Pull to load more");
                      } else if (mode == LoadStatus.loading) {
                        body = const CupertinoActivityIndicator();
                      } else if (mode == LoadStatus.failed) {
                        body = const Text("Load Failed! Click retry!");
                      } else if (mode == LoadStatus.canLoading) {
                        body = const Text("Release to load more");
                      } else {
                        body = const Text("No more Data");
                      }
                      return SizedBox(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      ...comments.map((comment) {
                        return Dismissible(
                          key: ValueKey(comment.commentId),
                          direction: DismissDirection.horizontal,
                          onDismissed: (dir) async {
                            await BiplusMediaAPI().deleteComment(
                                mediaId: widget.mediaId,
                                commentId: comment.commentId??0);
                            setState(() {
                              comments.remove(comment);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Card(
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(100.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      errorWidget: (context, _, __) =>
                                      const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                          'assets/cover.jpg',
                                        ),
                                      ),
                                      imageUrl:
                                      Uri.decodeFull(comment.avatar ?? ''),
                                      placeholder: (context, url) =>
                                      const Image(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                          'assets/cover.jpg',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Card(
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Container(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              comment.content ?? '',
                                              overflow: TextOverflow.clip,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )))),
                              ],
                            ),
                          ),
                        );
                      }).toList()
                    ],
                  )),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: TextField(
                    controller: commentController,
                    onChanged: (content) => {},
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      //  labelStyle: TextStyle(color: Colors.white),
                      labelText: 'Comment',
                      helperText: '',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary)),
                    ),
                  )),
              IconButton(
                  iconSize: 24,
                  onPressed: () async {
                    var content = commentController.text;
                    Comment? comment = await BiplusMediaAPI()
                        .addComment(mediaId: widget.mediaId, content: content);
                    if (comment != null){
                      setState(() {
                        comments.add(comment);
                        commentController.text = '';
                      });
                    }
                  },
                  icon: const Icon(Icons.send))
            ],
          )
        ],
      )
    );
  }
}
