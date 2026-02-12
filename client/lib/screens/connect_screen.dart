import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../services/api_config.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _serverInput = TextEditingController();
  bool _isScanning = false;
  bool _isTestingManual = false;
  bool _cancelScan = false;
  int _scannedHosts = 0;
  int _totalHosts = 0;
  String _status = '';

  @override
  void dispose() {
    _serverInput.dispose();
    super.dispose();
  }

  Future<void> _findLocalServer() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _cancelScan = false;
      _status = 'Scanning local network...';
      _scannedHosts = 0;
      _totalHosts = 0;
    });

    final prefixes = await _discoverPrefixes();
    final queue = Queue<String>();
    for (final prefix in prefixes) {
      for (var host = 1; host <= 254; host++) {
        queue.add('$prefix.$host');
      }
    }

    setState(() => _totalHosts = queue.length);

    String? foundBaseUrl;
    final workers = <Future<void>>[];
    for (var i = 0; i < 20; i++) {
      workers.add(Future<void>(() async {
        while (queue.isNotEmpty && !_cancelScan && foundBaseUrl == null) {
          final ip = queue.removeFirst();
          final isHealthy = await _checkHealth('http://$ip:8080');
          if (!mounted) return;
          setState(() => _scannedHosts++);
          if (isHealthy) {
            foundBaseUrl = 'http://$ip:8080';
            break;
          }
        }
      }));
    }

    await Future.wait(workers);
    if (!mounted) return;

    if (_cancelScan) {
      setState(() {
        _isScanning = false;
        _status = 'Scan canceled.';
      });
      return;
    }

    if (foundBaseUrl != null) {
      await ApiConfig.instance.saveBaseUrl(foundBaseUrl!);
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _status = 'Connected to $foundBaseUrl';
      });
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    setState(() {
      _isScanning = false;
      _status = 'No local server found on port 8080.';
    });
  }

  Future<Set<String>> _discoverPrefixes() async {
    final prefixes = <String>{};
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          final octets = addr.address.split('.');
          if (octets.length == 4) {
            prefixes.add('${octets[0]}.${octets[1]}.${octets[2]}');
          }
        }
      }
    } catch (_) {
      // fallback below
    }

    if (prefixes.isEmpty) {
      prefixes.addAll(const {'192.168.0', '192.168.1', '10.0.0'});
    }
    return prefixes;
  }

  Future<bool> _checkHealth(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(milliseconds: 500));
      if (response.statusCode != 200) return false;
      return response.body.contains('"ok":true') || response.body.contains('"ok": true');
    } catch (_) {
      return false;
    }
  }

  Future<void> _connectManual() async {
    final input = _serverInput.text.trim().replaceAll(RegExp(r'/+$'), '');
    if (input.isEmpty) {
      setState(() => _status = 'Enter a server URL first.');
      return;
    }

    setState(() {
      _isTestingManual = true;
      _status = 'Testing $input ...';
    });

    final ok = await _checkHealth(input);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _isTestingManual = false;
        _status = 'Could not reach $input/health';
      });
      return;
    }

    await ApiConfig.instance.saveBaseUrl(input);
    if (!mounted) return;
    setState(() {
      _isTestingManual = false;
      _status = 'Connected to $input';
    });
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return LiquidGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Connect to server'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Set up your Cora API endpoint before signing up or logging in.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isScanning ? null : _findLocalServer,
                      icon: const Icon(Icons.wifi_find),
                      label: const Text('Find local server'),
                    ),
                    if (_isScanning) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalHosts == 0 ? null : _scannedHosts / _totalHosts,
                      ),
                      const SizedBox(height: 6),
                      Text('Scanning $_scannedHosts / $_totalHosts hosts'),
                      TextButton(
                        onPressed: () => setState(() => _cancelScan = true),
                        child: const Text('Cancel scan'),
                      ),
                    ],
                    const Divider(height: 28),
                    TextField(
                      controller: _serverInput,
                      decoration: const InputDecoration(
                        labelText: 'Enter server address',
                        hintText: 'http://192.168.178.158:8080',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _isTestingManual ? null : _connectManual,
                      child: const Text('Test and continue'),
                    ),
                    if (_status.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(_status),
                    ],
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
