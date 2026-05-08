import 'package:flutter/material.dart';

/// Wraps a table builder so the first frame renders a loading indicator,
/// then after the frame the real content builds. Prevents synchronous
/// table construction from blocking the visible route change.
class DeferredTable extends StatefulWidget {
  final Widget Function() builder;
  final Future<void> Function()? onReady;

  const DeferredTable({super.key, required this.builder, this.onReady});

  @override
  State<DeferredTable> createState() => _DeferredTableState();
}

class _DeferredTableState extends State<DeferredTable> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      await widget.onReady?.call();
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    return widget.builder();
  }
}
