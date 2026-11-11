import 'dart:math' as math;
import 'package:flutter/material.dart';

// ===============================================
// ENGINE ANIMASI GAMIFIKASI DUOLINGO AAA (DYLEKS)
// Animasi melayang (idle float), selebrasi melenting
// (elastic bounce), dan denyut taktil (breathing pulse).
// ===============================================

/// 1. Animasi Melayang Halus (Floating Bobbing)
/// Memberi ilusi hidup/bernapas pada maskot dan ubin aktif.
class AnimasiMelayang extends StatefulWidget {
  final Widget child;
  final double amplitudo;
  final Duration durasi;

  const AnimasiMelayang({
    super.key,
    required this.child,
    this.amplitudo = 6.0,
    this.durasi = const Duration(milliseconds: 2000),
  });

  @override
  State<AnimasiMelayang> createState() => _AnimasiMelayangState();
}

class _AnimasiMelayangState extends State<AnimasiMelayang> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.durasi)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double pergeseran = math.sin(_controller.value * math.pi) * widget.amplitudo;
        return Transform.translate(
          offset: Offset(0, -pergeseran),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 2. Animasi Selebrasi Melenting (Celebration Elastic Bounce)
/// Efek pop-up memantul gembira saat tahap selesai atau reward didapat.
class AnimasiRayakan extends StatefulWidget {
  final Widget child;
  final Duration durasi;

  const AnimasiRayakan({
    super.key,
    required this.child,
    this.durasi = const Duration(milliseconds: 900),
  });

  @override
  State<AnimasiRayakan> createState() => _AnimasiRayakanState();
}

class _AnimasiRayakanState extends State<AnimasiRayakan> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _skala;
  late final Animation<double> _rotasi;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.durasi);
    _skala = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _rotasi = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _skala.value,
          child: Transform.rotate(
            angle: _rotasi.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// 3. Animasi Denyut Taktil (Pulse Breathing Glow)
/// Efek denyut ukuran halus untuk menarik perhatian anak ke tombol aksi / reward.
class AnimasiDenyut extends StatefulWidget {
  final Widget child;
  final double skalaMaks;
  final Duration durasi;

  const AnimasiDenyut({
    super.key,
    required this.child,
    this.skalaMaks = 1.06,
    this.durasi = const Duration(milliseconds: 1400),
  });

  @override
  State<AnimasiDenyut> createState() => _AnimasiDenyutState();
}

class _AnimasiDenyutState extends State<AnimasiDenyut> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animasi;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.durasi)..repeat(reverse: true);
    _animasi = Tween<double>(begin: 1.0, end: widget.skalaMaks).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animasi,
      builder: (context, child) {
        return Transform.scale(
          scale: _animasi.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
