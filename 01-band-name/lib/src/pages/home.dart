import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:services_application/src/models/band.dart';

import '../services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketServices = Provider.of<SocketServices>(context, listen: false);
    socketServices.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketServices = Provider.of<SocketServices>(context, listen: false);
    socketServices.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketServices = Provider.of<SocketServices>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketServices.serverStatus == ServerStatus.Online)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
        backgroundColor: Colors.white,
        title: const Text(
          'BandNames ',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Column(children: [
        (bands.isNotEmpty)
            ? _showGraph()
            : Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Center(
                  child: Text(
                    'No hay bandas :(',
                  ),
                ),
              ),
        Expanded(
          child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) => _bandTile(bands[index])),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketServices = Provider.of<SocketServices>(context, listen: false);
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          socketServices.socket.emit('delete-band', {'id': band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 10),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Eliminar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
          leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text(band.name!.substring(0, 2))),
          title: Text(band.name!),
          trailing: Text(
            '${band.votes}',
            style: const TextStyle(fontSize: 20),
          ),
          onTap: () =>
              socketServices.socket.emit('vote-band', {'id': band.id})),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      // para Android
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('Nueva banda'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                    onPressed: () => addBandToList(textController.text),
                    elevation: 5,
                    textColor: Colors.blue,
                    child: const Text('Add'),
                  )
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: const Text('Nueva banda'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Add'),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text('Cerrar'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ));
  }

  addBandToList(String name) {
    final socketServices = Provider.of<SocketServices>(context, listen: false);
    if (name.length > 1) {
      //podemos agregar
      socketServices.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    // ignore: prefer_collection_literals
    Map<String, double> dataMap = Map();
    for (var band in bands) {
      dataMap.putIfAbsent(band.name!, () => band.votes!.toDouble());
    }

    final List<Color> colorList = [
      Colors.blue[300] as Color,
      Colors.red[400] as Color,
      Colors.purple[400] as Color,
      Colors.blue[500] as Color,
      Colors.purple[300] as Color,
      Colors.red[300] as Color,
    ];

    return SizedBox(
        width: double.infinity,
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: const Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          ringStrokeWidth: 32,
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ));
  }
}
