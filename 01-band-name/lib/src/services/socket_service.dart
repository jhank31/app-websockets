import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ignore: constant_identifier_names
enum ServerStatus { Online, Offline, Connecting }

class SocketServices with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  SocketServices() {
    _initConfig();
  }

  void _initConfig() {
    _socket = IO.io('http://192.168.1.74:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }
}
