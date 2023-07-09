import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicTile extends StatelessWidget {
  final SongModel songModel;

  const MusicTile({
    required this.songModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        songModel.displayNameWOExt,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      leading: QueryArtworkWidget(
        id: songModel.id,
        type: ArtworkType.AUDIO,
        nullArtworkWidget: const Icon(Icons.music_note),
      ),
    );
  }
}
