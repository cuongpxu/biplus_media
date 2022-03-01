
import 'package:audio_service/audio_service.dart';
import 'package:biplus_media/src/helpers/playlist_helper.dart';
import 'package:biplus_media/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LikeButton extends StatefulWidget {
  final MediaItem? mediaItem;
  final double? size;
  final Map? data;
  final bool showSnack;
  final void Function()? onLikeChange;
  const LikeButton({
    Key? key,
    required this.mediaItem,
    this.size,
    this.data,
    this.showSnack = false,
    this.onLikeChange
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  bool liked = false;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _curve;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _curve = CurvedAnimation(parent: _controller, curve: Curves.slowMiddle);

    _scale = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 50,
      ),
    ]).animate(_curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItem != null) {
      liked = widget.mediaItem?.extras?['is_like'] ?? false;
    } else {
      liked = widget.data!['is_like'];
    }
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        icon: Icon(
          Icons.thumb_up,
          color: liked ? Theme.of(context).colorScheme.secondary : Theme.of(context).iconTheme.color,
        ),
        iconSize: widget.size ?? 24.0,
        tooltip: liked
            ? AppLocalizations.of(context)!.unlike
            : AppLocalizations.of(context)!.like,
        onPressed: () async {
          widget.onLikeChange?.call();
          if (!liked) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
          setState(() {
            liked = !liked;
            if (widget.mediaItem != null) {
              widget.mediaItem?.extras?['is_like'] = liked;
            } else {
              widget.data!['is_like'] = liked;
            }
          });
        },
      ),
    );
  }
}
