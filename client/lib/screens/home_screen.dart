import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/cora_theme.dart';
import '../widgets/cora_scaffold.dart';
import '../widgets/glass_surface.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _notes;

  bool _featuresExpanded = false;
  bool _fixesExpanded = false;
  bool _summaryExpanded = true;

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

  Widget _buildCard(
    String title,
    List<dynamic> lines, {
    bool expanded = true,
    ValueChanged<bool>? onTap,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: CoraTokens.spaceSm),
            child: Text('• $line'),
          ),
      ],
    );

    // Desktop cards (no expand/collapse)
    if (onTap == null) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: CoraTokens.spaceSm),
            content,
          ],
        ),
      );
    }

    // Mobile cards (expand/collapse)
    return GlassCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        initiallyExpanded: expanded,
        onExpansionChanged: onTap,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: CoraTokens.spaceSm),
            child: content,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = _notes;
    final mobile = MediaQuery.sizeOf(context).width < 600;

    return CoraScaffold(
      title: 'Welcome to Cora!',
      currentIndex: 0,
      child: notes == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Text('Version ${notes['version']} • ${notes['date']}'),
                const SizedBox(height: CoraTokens.spaceMd),
                if (mobile) ...[
                  _buildCard(
                    'Feature Updates',
                    notes['features'] as List<dynamic>,
                    expanded: _featuresExpanded,
                    onTap: (value) => setState(() => _featuresExpanded = value),
                  ),
                  const SizedBox(height: CoraTokens.spaceMd),
                  _buildCard(
                    'Bug Fixes',
                    notes['fixes'] as List<dynamic>,
                    expanded: _fixesExpanded,
                    onTap: (value) => setState(() => _fixesExpanded = value),
                  ),
                  const SizedBox(height: CoraTokens.spaceMd),
                  _buildCard(
                    'Summary',
                    notes['summary'] as List<dynamic>,
                    expanded: _summaryExpanded,
                    onTap: (value) => setState(() => _summaryExpanded = value),
                  ),
                ] else
                  Wrap(
                    spacing: CoraTokens.spaceMd,
                    runSpacing: CoraTokens.spaceMd,
                    children: [
                      SizedBox(
                        width: 320,
                        child: _buildCard(
                          'Feature Updates',
                          notes['features'] as List<dynamic>,
                          onTap: null,
                        ),
                      ),
                      SizedBox(
                        width: 320,
                        child: _buildCard(
                          'Bug Fixes',
                          notes['fixes'] as List<dynamic>,
                          onTap: null,
                        ),
                      ),
                      SizedBox(
                        width: 320,
                        child: _buildCard(
                          'Summary',
                          notes['summary'] as List<dynamic>,
                          onTap: null,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}
