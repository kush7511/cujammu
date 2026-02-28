import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class CujRadioPage extends StatefulWidget {
  const CujRadioPage({super.key});

  @override
  State<CujRadioPage> createState() => _CujRadioPageState();
}

class _CujRadioPageState extends State<CujRadioPage> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  // 🔥 Replace this with your real radio streaming URL
  final String _radioUrl =
      "https://stream-153.zeno.fm/0r0xa792kwzuv"; 

  @override
  void initState() {
    super.initState();
    _initRadio();
  }

  Future<void> _initRadio() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _player.setUrl(_radioUrl);

      _player.playerStateStream.listen((state) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state.playing;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading radio: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CUJ Radio"),
        backgroundColor: const Color(0xFF003366),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF001A33)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.radio,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                "Central University of Jammu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Live Campus Radio",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : FloatingActionButton(
                      backgroundColor: Colors.pink,
                      onPressed: _togglePlay,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                    ),
              const SizedBox(height: 20),
              Text(
                _isPlaying ? "🔴 LIVE" : "Tap to Play",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}