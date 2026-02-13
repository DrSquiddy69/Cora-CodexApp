import 'package:flutter/material.dart';

import '../screens/chat_screen.dart';
import '../services/app_settings.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../theme/cora_theme.dart';
import 'glass_surface.dart';

class CoraShell extends StatefulWidget {
  const CoraShell({super.key});

  @override
  State<CoraShell> createState() => _CoraShellState();
}

class _CoraShellState extends State<CoraShell> {
  String? selectedSpace;
  String? selectedDmId;
  String? selectedChannelId;
  int mobileTabIndex = 0;

  final _spaces = const [
    _Space(id: 's1', name: 'Dev Hub', icon: Icons.terminal),
    _Space(id: 's2', name: 'Design', icon: Icons.palette_outlined),
  ];

  final _dms = const [
    _Dm(id: 'd1', name: 'Alex'),
    _Dm(id: 'd2', name: 'Sam'),
  ];

  final _channels = const {
    's1': [
      _Channel(id: 'c1', name: 'general'),
      _Channel(id: 'c2', name: 'builds'),
    ],
    's2': [
      _Channel(id: 'c3', name: 'ideas'),
      _Channel(id: 'c4', name: 'feedback'),
    ],
  };

  final _members = const {
    's1': ['You', 'Alex', 'Taylor'],
    's2': ['You', 'Sam'],
  };

  bool get isDmMode => selectedSpace == null;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(mobile ? _mobileTitle() : 'Cora'),
        ),
        body: SafeArea(
          child: mobile ? _buildMobileBody() : _buildDesktopBody(),
        ),
        bottomNavigationBar: mobile
            ? NavigationBar(
                selectedIndex: mobileTabIndex,
                onDestinationSelected: (index) => setState(() => mobileTabIndex = index),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'Servers'),
                  NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
                  NavigationDestination(icon: Icon(Icons.people_outline), label: 'Friends'),
                  NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
                ],
              )
            : null,
      ),
    );
  }

  String _mobileTitle() {
    return switch (mobileTabIndex) {
      0 => 'Welcome to Cora!',
      1 => 'Servers',
      2 => 'Chats',
      3 => 'Friends',
      _ => 'Settings',
    };
  }

  Widget _buildDesktopBody() {
    return Padding(
      padding: const EdgeInsets.all(CoraTokens.spaceMd),
      child: Row(
        children: [
          SizedBox(width: 86, child: _buildServerRail()),
          const SizedBox(width: CoraTokens.spaceMd),
          SizedBox(width: 250, child: _buildListPanel()),
          const SizedBox(width: CoraTokens.spaceMd),
          Expanded(child: _buildChatPanel()),
          const SizedBox(width: CoraTokens.spaceMd),
          SizedBox(width: 220, child: _buildMemberPanel()),
        ],
      ),
    );
  }

  Widget _buildMobileBody() {
    return Padding(
      padding: const EdgeInsets.all(CoraTokens.spaceSm),
      child: switch (mobileTabIndex) {
        0 => const HomePanel(),
        1 => GlassCard(child: _buildServersStacked()),
        2 => GlassCard(child: _buildChatsStacked()),
        3 => GlassCard(child: _buildFriendsStacked()),
        _ => const SettingsPanel(),
      },
    );
  }

  Widget _buildServerRail() {
    return GlassCard(
      opacity: 0.08,
      padding: const EdgeInsets.symmetric(vertical: CoraTokens.spaceMd, horizontal: CoraTokens.spaceSm),
      child: Column(
        children: [
          IconButton.filledTonal(
            tooltip: 'DM/Friends mode',
            onPressed: () => setState(() {
              selectedSpace = null;
              selectedChannelId = null;
            }),
            icon: const Icon(Icons.forum_outlined),
          ),
          const SizedBox(height: CoraTokens.spaceSm),
          IconButton(
            tooltip: 'Create group/server',
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline),
          ),
          const Divider(),
          if (_spaces.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: CoraTokens.spaceSm),
              child: Text('No servers', textAlign: TextAlign.center),
            )
          else
            ..._spaces.map(
              (space) => Padding(
                padding: const EdgeInsets.only(bottom: CoraTokens.spaceSm),
                child: Tooltip(
                  message: space.name,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(CoraTokens.radiusMd),
                    onTap: () => setState(() {
                      selectedSpace = space.id;
                      selectedDmId = null;
                      selectedChannelId = _channels[space.id]?.first.id;
                    }),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selectedSpace == space.id
                            ? Colors.white.withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(CoraTokens.radiusMd),
                        border: Border(
                          left: BorderSide(
                            color: selectedSpace == space.id ? const Color(0xFF53D6FF) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Icon(space.icon),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListPanel() {
    if (isDmMode) {
      return GlassCard(
        opacity: 0.1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Friends / DMs', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: CoraTokens.spaceSm),
            ..._dms.map(
              (dm) => ListTile(
                contentPadding: EdgeInsets.zero,
                selected: selectedDmId == dm.id,
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(dm.name),
                trailing: TextButton(
                  onPressed: () => setState(() {
                    selectedDmId = dm.id;
                    selectedChannelId = null;
                  }),
                  child: const Text('Message'),
                ),
                onTap: () => setState(() {
                  selectedDmId = dm.id;
                  selectedChannelId = null;
                }),
              ),
            ),
          ],
        ),
      );
    }

    final channels = _channels[selectedSpace] ?? const <_Channel>[];
    return GlassCard(
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Channels', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: CoraTokens.spaceSm),
          if (channels.isEmpty)
            const Text('No channels yet')
          else
            ...channels.map(
              (channel) => ListTile(
                contentPadding: EdgeInsets.zero,
                selected: channel.id == selectedChannelId,
                leading: const Icon(Icons.tag),
                title: Text(channel.name),
                onTap: () => setState(() => selectedChannelId = channel.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatPanel() {
    final hasSelection = isDmMode ? selectedDmId != null : selectedChannelId != null;
    final title = isDmMode
        ? selectedDmId == null
            ? 'Direct messages'
            : 'Chat with ${_dms.firstWhere((d) => d.id == selectedDmId).name}'
        : selectedChannelId == null
            ? 'Select channel'
            : '#${(_channels[selectedSpace] ?? const <_Channel>[]).firstWhere((c) => c.id == selectedChannelId).name}';

    return GlassCard(
      opacity: 0.12,
      child: hasSelection
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Divider(),
                Expanded(child: ChatScreen(enterToSend: AppSettings.enterToSend)),
              ],
            )
          : const HomePanel(),
    );
  }

  Widget _buildMemberPanel() {
    if (isDmMode) {
      return GlassCard(
        opacity: 0.08,
        child: const Center(child: Text('DM mode active')),
      );
    }

    final members = _members[selectedSpace] ?? const <String>[];
    return GlassCard(
      opacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Members', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: CoraTokens.spaceSm),
          ...members.map((name) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_outline), title: Text(name))),
        ],
      ),
    );
  }

  Widget _buildServersStacked() {
    return ListView(
      children: [
        const Text('Servers', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: CoraTokens.spaceSm),
        ..._spaces.map(
          (space) => ListTile(
            leading: Icon(space.icon),
            title: Text(space.name),
            onTap: () => setState(() {
              selectedSpace = space.id;
              selectedChannelId = _channels[space.id]?.first.id;
            }),
          ),
        ),
        const Divider(),
        const Text('Channels', style: TextStyle(fontWeight: FontWeight.w700)),
        ...(_channels[selectedSpace] ?? const <_Channel>[]).map((channel) => ListTile(
              leading: const Icon(Icons.tag),
              title: Text(channel.name),
              onTap: () => setState(() {
                selectedChannelId = channel.id;
                mobileTabIndex = 2;
              }),
            )),
      ],
    );
  }

  Widget _buildChatsStacked() {
    final list = isDmMode ? _dms.map((d) => d.name).toList() : (_channels[selectedSpace] ?? const <_Channel>[]).map((c) => '#${c.name}').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chats / DMs', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: CoraTokens.spaceSm),
        if (list.isEmpty)
          const Text('No conversations yet')
        else
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(list[index]),
                subtitle: const Text('Tap to open chat'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFriendsStacked() {
    return ListView(
      children: [
        const Text('Friends', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: CoraTokens.spaceSm),
        ..._dms.map((dm) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(dm.name),
              trailing: TextButton(
                onPressed: () => setState(() {
                  selectedSpace = null;
                  selectedDmId = dm.id;
                  mobileTabIndex = 2;
                }),
                child: const Text('Message'),
              ),
            )),
      ],
    );
  }
}

class _Space {
  const _Space({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final IconData icon;
}

class _Channel {
  const _Channel({required this.id, required this.name});

  final String id;
  final String name;
}

class _Dm {
  const _Dm({required this.id, required this.name});

  final String id;
  final String name;
}
