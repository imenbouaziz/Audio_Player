import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'Downloads.dart';

import '../../../../provider/song_model_provider.dart';

class NowPlaying extends StatefulWidget {
  final List<SongModel> songModelList;
  final AudioPlayer audioPlayer;

  const NowPlaying({
    Key? key,
    required this.songModelList,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool _isPlaying = false;
  List<AudioSource> songList = [];
  int currentIndex = 0;

  void popBack() {
    Navigator.pop(context);
  }

  void seekToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }

  @override
  void initState() {
    super.initState();
    parseSong();
  }

  void parseSong() {
    try {
      for (var element in widget.songModelList) {
        songList.add(
          AudioSource.uri(
            Uri.parse(element.uri!),
            tag: MediaItem(
              id: element.id.toString(),
              title: element.displayNameWOExt,
              artUri: Uri.parse(element.id.toString()),
            ),
          ),
        );
      }

      widget.audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: songList),
      );
      widget.audioPlayer.play();
      _isPlaying = true;

      widget.audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });
      widget.audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      listenToEvent();
      listenToSongIndex();
    } on Exception catch (_) {
      popBack();
    }
  }

  void listenToEvent() {
    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void listenToSongIndex() {
    widget.audioPlayer.currentIndexStream.listen(
      (event) {
        setState(
          () {
            if (event != null) {
              currentIndex = event;
            }
            context
                .read<SongModelProvider>()
                .setId(widget.songModelList[currentIndex].id);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: height,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Downloads()),
                      );
                    },
                    icon: const Icon(
                      Icons.download,
                      size: 40.0,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Center(
                child: ArtWorkWidget(),
              ),
              const SizedBox(height: 15.0),
              Text(
                widget.songModelList[currentIndex].displayNameWOExt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 15.0),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (widget.audioPlayer.hasPrevious) {
                          widget.audioPlayer.seekToPrevious();
                        }
                      },
                      icon: const Icon(
                        Icons.skip_previous,
                        size: 60.0,
                        color: Colors.purple,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isPlaying) {
                            widget.audioPlayer.pause();
                          } else {
                            if (_position >= _duration) {
                              seekToSeconds(0);
                            } else {
                              widget.audioPlayer.play();
                            }
                          }
                          _isPlaying = !_isPlaying;
                        });
                      },
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 60.0,
                        color: Colors.purple,
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    IconButton(
                      onPressed: () {
                        if (widget.audioPlayer.hasNext) {
                          widget.audioPlayer.seekToNext();
                        }
                      },
                      icon: const Icon(
                        Icons.skip_next,
                        size: 60.0,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 300,
      artworkWidth: 300,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: Image.asset("assets/empty_cover.jpeg"),
    );
  }
}
