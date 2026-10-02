import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class BT6Music extends StatelessWidget {
  const BT6Music({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF080608),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB00078),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({
    super.key,
  });

  @override
  State<MusicPlayerScreen> createState() =>
      _MusicPlayerScreenState();
}

class _MusicPlayerScreenState
    extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer =
      AudioPlayer();

  final List<String> _songs = [
    'assets/audios/sample1.mp3',
    'assets/audios/sample2.mp3',
    'assets/audios/sample3.mp3',
  ];

  final List<String> _songTitles = [
    'Midnight Dreams',
    'Lost in the Stars',
    'Beautiful Day',
  ];

  final List<String> _artists = [
    'Nguyen Artist',
    'Dream Music',
    'Summer Band',
  ];

  int _currentSongIndex = 0;

  bool _isPlaying = false;

  Duration _duration = Duration.zero;

  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen(
      (PlayerState state) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isPlaying =
              state == PlayerState.playing;
        });
      },
    );

    _audioPlayer.onDurationChanged.listen(
      (Duration duration) {
        if (!mounted) {
          return;
        }

        setState(() {
          _duration = duration;
        });
      },
    );

    _audioPlayer.onPositionChanged.listen(
      (Duration position) {
        if (!mounted) {
          return;
        }

        setState(() {
          _position = position;
        });
      },
    );

    _audioPlayer.onPlayerComplete.listen(
      (_) {
        _nextSong();
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong() async {
    try {
      await _audioPlayer.play(
        AssetSource(
          _songs[_currentSongIndex]
              .replaceFirst('assets/', ''),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể phát bài hát: $e',
          ),
        ),
      );
    }
  }

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopSong() async {
    await _audioPlayer.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _position = Duration.zero;
      _isPlaying = false;
    });
  }

  Future<void> _nextSong() async {
    await _audioPlayer.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      if (_currentSongIndex <
          _songs.length - 1) {
        _currentSongIndex++;
      } else {
        _currentSongIndex = 0;
      }

      _position = Duration.zero;
      _duration = Duration.zero;
    });

    await _playSong();
  }

  Future<void> _previousSong() async {
    await _audioPlayer.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      if (_currentSongIndex > 0) {
        _currentSongIndex--;
      } else {
        _currentSongIndex =
            _songs.length - 1;
      }

      _position = Duration.zero;
      _duration = Duration.zero;
    });

    await _playSong();
  }

  Future<void> _selectSong(
    int index,
  ) async {
    await _audioPlayer.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _currentSongIndex = index;
      _position = Duration.zero;
      _duration = Duration.zero;
      _isPlaying = false;
    });

    await _playSong();
  }

  Future<void> _seekSong(
    double value,
  ) async {
    final Duration position =
        Duration(
      milliseconds: value.toInt(),
    );

    await _audioPlayer.seek(position);
  }

  String _formatDuration(
    Duration duration,
  ) {
    final int minutes =
        duration.inMinutes;

    final int seconds =
        duration.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF090909),
            Color(0xFF21142B),
            Color(0xFFB00078),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB00078)
                .withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            child: Text(
              'ALBUM',
              style: TextStyle(
                color: Colors.white
                    .withOpacity(0.75),
                fontSize: 13,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
          ),

          Container(
            width: 165,
            height: 165,
            decoration:
                const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Container(
              margin:
                  const EdgeInsets.all(12),
              decoration:
                  const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF19151E),
              ),
              child: Container(
                margin:
                    const EdgeInsets.all(25),
                decoration:
                    const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFFB00078),
                  size: 45,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 25,
            child: Column(
              children: [
                Text(
                  _songTitles[
                      _currentSongIndex]
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  _artists[
                      _currentSongIndex]
                      .toUpperCase(),
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.7),
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    final double maxValue =
        _duration.inMilliseconds
            .toDouble();

    final double currentValue =
        _position.inMilliseconds
            .toDouble()
            .clamp(
              0,
              maxValue > 0
                  ? maxValue
                  : 1,
            );

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context)
              .copyWith(
            activeTrackColor:
                const Color(0xFFB00078),
            inactiveTrackColor:
                Colors.white24,
            thumbColor:
                const Color(0xFFB00078),
            overlayColor:
                const Color(0x33B00078),
            trackHeight: 3,
          ),
          child: Slider(
            value: currentValue,
            min: 0,
            max: maxValue > 0
                ? maxValue
                : 1,
            onChanged: maxValue <= 0
                ? null
                : _seekSong,
          ),
        ),

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(
                _formatDuration(
                  _position,
                ),
                style: TextStyle(
                  color: Colors.white
                      .withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
              Text(
                _formatDuration(
                  _duration,
                ),
                style: TextStyle(
                  color: Colors.white
                      .withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
              ),
              color: Colors.white,
              iconSize: 32,
              onPressed:
                  _previousSong,
            ),

            const SizedBox(
              width: 10,
            ),

            Container(
              width: 58,
              height: 58,
              decoration:
                  const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB00078),
              ),
              child: IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                color: Colors.white,
                iconSize: 32,
                onPressed: () {
                  if (_isPlaying) {
                    _pauseSong();
                  } else {
                    _playSong();
                  }
                },
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            IconButton(
              icon: const Icon(
                Icons.stop,
              ),
              color: Colors.white,
              iconSize: 30,
              onPressed:
                  _stopSong,
            ),

            const SizedBox(
              width: 10,
            ),

            IconButton(
              icon: const Icon(
                Icons.skip_next,
              ),
              color: Colors.white,
              iconSize: 32,
              onPressed:
                  _nextSong,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSongList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141014),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFB00078)
              .withOpacity(0.35),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.queue_music,
                  color: Color(0xFFB00078),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Expanded(
                  child: Text(
                    'PLAYLIST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Text(
                  '${_songs.length} SONGS',
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.45),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: Colors.white12,
            height: 1,
          ),

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemCount: _songs.length,
              itemBuilder:
                  (context, index) {
                final bool selected =
                    index ==
                        _currentSongIndex;

                return InkWell(
                  onTap: () {
                    _selectSong(index);
                  },
                  child: Container(
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? const Color(
                              0xFFB00078,
                            ).withOpacity(
                              0.18,
                            )
                          : Colors
                              .transparent,
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${index + 1}',
                            style:
                                TextStyle(
                              color: selected
                                  ? const Color(
                                      0xFFB00078,
                                    )
                                  : Colors
                                      .white54,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        Container(
                          width: 42,
                          height: 42,
                          decoration:
                              BoxDecoration(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                            gradient:
                                LinearGradient(
                              colors: [
                                const Color(
                                  0xFF2A1A2F,
                                ),
                                const Color(
                                  0xFFB00078,
                                ).withOpacity(
                                  0.7,
                                ),
                              ],
                            ),
                          ),
                          child: Icon(
                            selected &&
                                    _isPlaying
                                ? Icons
                                    .equalizer
                                : Icons
                                    .music_note,
                            color: Colors
                                .white,
                            size: 20,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                _songTitles[
                                    index],
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,
                                  fontSize:
                                      14,
                                  fontWeight:
                                      selected
                                          ? FontWeight
                                              .bold
                                          : FontWeight
                                              .normal,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                _artists[
                                    index],
                                style:
                                    TextStyle(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    0.45,
                                  ),
                                  fontSize:
                                      11,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          '3:00',
                          style: TextStyle(
                            color: Colors
                                .white
                                .withOpacity(
                              0.45,
                            ),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF080608),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MUSIC PLAYER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isWide =
                constraints.maxWidth >= 700;

            if (isWide) {
              return Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          _buildAlbumArt(),

                          const SizedBox(
                            height: 28,
                          ),

                          Text(
                            _songTitles[
                                _currentSongIndex],
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            _artists[
                                _currentSongIndex],
                            style:
                                TextStyle(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.5,
                              ),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          _buildPlayerControls(),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 24,
                    ),

                    Expanded(
                      flex: 4,
                      child:
                          _buildSongList(),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                18,
              ),
              child: Column(
                children: [
                  _buildAlbumArt(),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    _songTitles[
                        _currentSongIndex],
                    textAlign:
                        TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    _artists[
                        _currentSongIndex],
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(
                        0.5,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  _buildPlayerControls(),

                  const SizedBox(
                    height: 25,
                  ),

                  SizedBox(
                    height: 330,
                    child:
                        _buildSongList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}