import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/cora_theme.dart';
import '../widgets/glass_surface.dart';

class HomePanel extends StatefulWidget {
  const HomePanel({super.key});

  @override
  State<HomePanel> createState() => _HomePanelState();
}

class _HomePanelState extends State<HomePanel> {
  Map<String, dynamic>? _notes;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final raw = await rootBundle.loadString('assets/patch_notes.json');
    if (!mounted) return;
    setState(() => _notes = jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final notes = _notes;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1100
        ? 3
        : width >= 700
            ? 2
            : 1;

    if (notes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final cards = [
      _PatchCard(title: 'Feature Updates', lines: (notes['features'] as List<dynamic>).cast<String>()),
      _PatchCard(title: 'Bug Fixes', lines: (notes['fixes'] as List<dynamic>).cast<String>()),
      _PatchCard(title: 'Summary', lines: (notes['summary'] as List<dynamic>).cast<String>()),
    ];

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView(
          padding: const EdgeInsets.all(CoraTokens.spaceMd),
          children: [
            const Text('Welcome to Cora!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: CoraTokens.spaceSm),
            Text('Version ${notes['version']} • ${notes['date']}'),
            const SizedBox(height: CoraTokens.spaceMd),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: columns,
              crossAxisSpacing: CoraTokens.spaceMd,
              mainAxisSpacing: CoraTokens.spaceMd,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: columns == 1 ? 2.1 : 1.2,
              children: cards,
            ),
          ],
        ),
      ),
    );
  }
}

class _PatchCard extends StatelessWidget {
  const _PatchCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: CoraTokens.spaceSm),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $line'),
            ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Home')),
        body: const HomePanel(),
      ),
    );
  }
}
