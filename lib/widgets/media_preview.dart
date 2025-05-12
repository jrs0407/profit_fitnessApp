import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MediaPreview extends StatelessWidget {
  final String url;
  final YoutubePlayerController? youtubeController;

  const MediaPreview({
    Key? key,
    required this.url,
    this.youtubeController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const SizedBox.shrink();

    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null && youtubeController != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: YoutubePlayer(
          controller: youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Text(
            'No se pudo cargar la imagen',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}