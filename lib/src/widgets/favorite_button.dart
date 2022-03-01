
import 'package:audio_service/audio_service.dart';
import 'package:biplus_media/src/helpers/playlist_helper.dart';
import 'package:biplus_media/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavoriteButton extends StatefulWidget {
  final MediaItem? mediaItem;
  final double? size;
  final Map? data;
  final bool showSnack;
  final void Function()? onLikeChange;
  const FavoriteButton({
    Key? key,
    required this.mediaItem,
    this.size,
    this.data,
    this.showSnack = false,
    this.onLikeChange
  }) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
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
      isFavorite = widget.mediaItem?.extras?['is_favourite'] ?? false;
    } else {
      isFavorite = widget.data!['is_favourite'];
    }
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? Colors.redAccent : Theme.of(context).iconTheme.color,
        ),
        iconSize: widget.size ?? 24.0,
        tooltip: isFavorite
            ? AppLocalizations.of(context)!.unlike
            : AppLocalizations.of(context)!.like,
        onPressed: () async {
          widget.onLikeChange?.call();
          if (!isFavorite) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
          setState(() {
            isFavorite = !isFavorite;
            if (widget.mediaItem != null) {
              widget.mediaItem?.extras?['is_favourite'] = isFavorite;
            } else {
              widget.data!['is_favourite'] = isFavorite;
            }
          });
          if (widget.showSnack) {
            ShowSnackBar().showSnackBar(
              context,
              isFavorite
                  ? AppLocalizations.of(context)!.addedToFav
                  : AppLocalizations.of(context)!.removedFromFav,
              action: SnackBarAction(
                textColor: Theme.of(context).colorScheme.secondary,
                label: AppLocalizations.of(context)!.undo,
                onPressed: () {
                },
              ),
            );
          }
        },
      ),
    );
  }
}
