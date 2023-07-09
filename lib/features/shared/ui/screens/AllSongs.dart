import 'NowPlaying.dart';
import '../../widgets/MusicTile.dart';
import '../../../../provider/song_model_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AllSongs extends StatefulWidget {
  const AllSongs({Key? key}) : super(key: key);

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> allSongs = [];

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  requestPermission() async {
    if (Platform.isAndroid) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Flutter Music Player",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 2,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        ),
        builder: (context, item) {
          if (item.data == null) {
            return Center(
              child: Column(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text("Waiting..")
                ],
              ),
            );
          }
          if (item.data!.isEmpty) {
            return const Center(child: Text("Nothing :("));
          }
          return Stack(
            children: [
              ListView.builder(
                itemCount: item.data!.length,
                itemBuilder: (context, index) {
                  allSongs.addAll(item.data!);
                  return GestureDetector(
                    onTap: () {
                      context
                          .read<SongModelProvider>()
                          .setId(item.data![index].id);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NowPlaying(
                                  songModelList: allSongs,
                                  audioPlayer: _audioPlayer)));
                    },
                    child: MusicTile(
                      songModel: item.data![index],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
