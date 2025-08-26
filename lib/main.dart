import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TikTokScrollerApp());
}

class TikTokScrollerApp extends StatelessWidget {
  const TikTokScrollerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vertical Scroller',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

enum FeedType { main, special }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FeedType currentFeed = FeedType.main;
  

  List<String> get _mainFeed => const [
        'assets/videos/clip.mp4',
        'assets/videos/clip1.mp4',
        'assets/videos/clip2.mp4',
        'assets/videos/clip3.mp4',
        'assets/videos/clip4.mp4',
        'assets/videos/clip5.mp4',
        'assets/videos/clip6.mp4',
        'assets/videos/clip7.mp4',
      ];

  List<String> get _specialFeed => const [
        'assets/videos/memorie1.mp4',
        'assets/videos/memorie2.mp4',
        'assets/videos/memorie3.mp4',
        'assets/videos/memorie4.mp4',
        'assets/videos/memorie5.mp4',
        'assets/videos/memorie6.mp4',
        'assets/videos/memorie7.mp4',
        'assets/videos/memorie8.mp4',
        'assets/videos/memorie9.mp4',
        'assets/videos/memorie10.mp4',
        'assets/videos/memorie11.mp4',
        'assets/videos/memorie12.mp4',
        'assets/videos/memorie13.mp4',
        'assets/videos/memorie14.mp4',
        'assets/videos/memorie15.mp4',
        'assets/videos/memorie16.mp4',
        'assets/videos/memorie17.mp4',
        'assets/videos/memorie18.mp4',
        'assets/videos/memorie19.mp4',
        'assets/videos/memorie20.mp4',
        'assets/videos/memorie21.mp4',
        'assets/videos/memorie22.mp4',

        
      ];

  Future<bool> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    bool granted = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (passwordController.text.trim() == "i love u") {
                  granted = true;
                }
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    return granted;
  }

  @override
  Widget build(BuildContext context) {
    final videos = currentFeed == FeedType.main ? _mainFeed : _specialFeed;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            VideoFeed(
              key: ValueKey(currentFeed),
              videos: videos,
            ),
            Positioned(
              top: 12,
              left: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FeedTab(
                      label: 'For You',
                      selected: currentFeed == FeedType.main,
                      onTap: () => setState(() => currentFeed = FeedType.main),
                    ),
                    _FeedTab(
                      label: 'Special Memories',
                      selected: currentFeed == FeedType.special,
                      onTap: () async {
                        final granted = await _showPasswordDialog(context);
                        if (granted) {
                          setState(() => currentFeed = FeedType.special);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Wrong password")),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FeedTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class VideoFeed extends StatefulWidget {
  final List<String> videos;
  const VideoFeed({super.key, required this.videos});

  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  late final PageController _pageController;
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _liked = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initControllerForPage(0);
    _preloadAround(0);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initControllerForPage(int index) async {
    if (_controllers[index] != null) return;
    final path = widget.videos[index % widget.videos.length];
    final controller = VideoPlayerController.asset(path);

    _controllers[index] = controller;
    await controller.initialize();
    controller.setLooping(true);

    if (kIsWeb) {
      // Autoplay policy: start muted to allow autoplay
      await controller.setVolume(100);
    }

    if (index == _currentPage) {
      unawaited(controller.play());
    }
    setState(() {});
  }

  void _preloadAround(int index) {
    final toKeep = <int>{index, index - 1, index + 1};
    for (final i in toKeep) {
      if (i >= 0 && i < widget.videos.length) {
        _initControllerForPage(i);
      }
    }
    final toDispose = _controllers.keys.where((k) => !toKeep.contains(k)).toList();
    for (final k in toDispose) {
      _controllers[k]?.dispose();
      _controllers.remove(k);
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _controllers.forEach((i, c) {
      if (i == index) {
        if (!c.value.isPlaying) c.play();
      } else {
        if (c.value.isPlaying) c.pause();
      }
    });
    _preloadAround(index);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        final controller = _controllers[index];
        final liked = _liked[index] ?? false;
        return VideoTile(
          key: ValueKey('tile_$index'),
          controller: controller,
          onDoubleTapLike: () => setState(() => _liked[index] = true),
          liked: liked,
          onToggleLike: () => setState(() => _liked[index] = !( _liked[index] ?? false)),
        );
      },
    );
  }
}

class VideoTile extends StatefulWidget {
  final VideoPlayerController? controller;
  final VoidCallback onDoubleTapLike;
  final VoidCallback onToggleLike;
  final bool liked;

  const VideoTile({super.key, required this.controller, required this.onDoubleTapLike, required this.onToggleLike, required this.liked});

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> with SingleTickerProviderStateMixin {
  bool _showBigHeart = false;
  bool _muted = true;

  late final AnimationController _heartAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _scale = Tween<double>(begin: 0.6, end: 1.2).animate(
    CurvedAnimation(parent: _heartAnim, curve: Curves.easeOutBack),
  );

  @override
  void dispose() {
    _heartAnim.dispose();
    super.dispose();
  }

  void _toggleMute() {
    final c = widget.controller;
    if (c == null) return;
    setState(() => _muted = !_muted);
    c.setVolume(_muted ? 0 : 1);
  }

  void _handleDoubleTap() {
    widget.onDoubleTapLike();
    setState(() => _showBigHeart = true);
    _heartAnim.forward(from: 0).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _showBigHeart = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      onTap: () {
        if (c == null) return;
        c.value.isPlaying ? c.pause() : c.play();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (c == null || !c.value.isInitialized)
            const _Loading()
          else
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),

          const _TopBottomFades(),

          Positioned(
            right: 12,
            bottom: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CircleButton(
                  icon: widget.liked ? Icons.favorite : Icons.favorite_border,
                  color: widget.liked ? Colors.pinkAccent : Colors.white,
                  onPressed: widget.onToggleLike,
                ),
                const SizedBox(height: 12),
                _CircleButton(
                  icon: _muted ? Icons.volume_off : Icons.volume_up,
                  onPressed: _toggleMute,
                ),
              ],
            ),
          ),

          if (_showBigHeart)
            Center(
              child: ScaleTransition(
                scale: _scale,
                child: Icon(Icons.favorite, size: 140, color: Colors.white.withOpacity(0.90)),
              ),
            ),

          Positioned(
            left: 16,
            bottom: 24,
            right: 84,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('sehar', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                SizedBox(height: 6),
                Text('Enjoy the vibes ✨', maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBottomFades extends StatelessWidget {
  const _TopBottomFades();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  const _CircleButton({required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, size: 28, color: color ?? Colors.white),
        ),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.black),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
