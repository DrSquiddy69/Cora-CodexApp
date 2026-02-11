import 'package:matrix/matrix.dart';

class MatrixService {
  MatrixService(this.homeserver);

  final Uri homeserver;
  Client? _client;

  Future<Client> init(String userId) async {
    final client = Client('cora-$userId');
    await client.checkHomeserver(homeserver);
    _client = client;
    return client;
  }

  Client? get client => _client;
}
