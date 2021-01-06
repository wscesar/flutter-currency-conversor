import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=1d9bdfe9";

void main() async {
  runApp(MaterialApp(home: Home()));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  final brlController = TextEditingController();
  final usdController = TextEditingController();

  void _clearValues() {
    brlController.text = '';
    usdController.text = '';
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearValues();
      return;
    }
    double value = double.parse(text);
    usdController.text = (value / dolar).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearValues();
      return;
    }
    double dolar = double.parse(text);
    brlController.text = (dolar * this.dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Conversor de Moedas")),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return errorMessage('Carregando...');
            default:
              if (snapshot.hasError) {
                return errorMessage('Erro ao Carregar Dados.');
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.blue,
                      ),
                      textField(
                        "Reais",
                        "R\$ ",
                        brlController,
                        _realChanged,
                      ),
                      textField(
                        "Dólares",
                        "US\$ ",
                        usdController,
                        _dolarChanged,
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget errorMessage(String message) {
  return Center(
    child: Text(
      message,
      style: TextStyle(fontSize: 25),
      textAlign: TextAlign.center,
    ),
  );
}

Widget textField(String label, String prefix, TextEditingController ctrl, Function foo) {
  return Padding(
    padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
    child: TextField(
      onChanged: foo,
      controller: ctrl,
      style: TextStyle(fontSize: 18),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: OutlineInputBorder(),
      ),
    ),
  );
}
