
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../models/mc.dart';

class HorizontalMCList extends StatelessWidget {
  final List mcList;
  final Function(int) onTap;
  const HorizontalMCList({
    Key? key,
    required this.mcList,
    required this.onTap,
  }) : super(key: key);

  String formatString(String? text) {
    return text == null
        ? ''
        : text
            .replaceAll('&amp;', '&')
            .replaceAll('&#039;', "'")
            .replaceAll('&quot;', '"')
            .trim();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize =
        MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    return SizedBox(
      height: boxSize + 10,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        itemCount: mcList.length,
        itemBuilder: (context, index) {
          Mc mc = mcList[index];
          final Map item = mc.toJson();
          return GestureDetector(
            onLongPress: () {
              Feedback.forLongPress(context);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    backgroundColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    content: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (context, _, __) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/artist.png'),
                        ),
                        imageUrl: Uri.decodeFull(item['avatar'].toString()),
                        placeholder: (context, url) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/artist.png'),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            onTap: () {
              onTap(index);
            },
            child: SizedBox(
              width: boxSize - 30,
              child: Column(
                children: [
                  SizedBox.square(
                    dimension: boxSize - 30,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        errorWidget: (context, _, __) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/artist.png'),
                        ),
                        imageUrl: Uri.decodeFull(item['avatar']),
                        placeholder: (context, url) => const Image(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            'assets/artist.png',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    formatString(item['name']?.toString()),
                    textAlign: TextAlign.center,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
