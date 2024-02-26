import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Field Selector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JsonFieldSelector(),
    );
  }
}

class JsonFieldSelector extends StatefulWidget {
  @override
  _JsonFieldSelectorState createState() => _JsonFieldSelectorState();
}

class _JsonFieldSelectorState extends State<JsonFieldSelector> {
  String _originalJson = '';
  List<dynamic> _selectedFields = [];
  String _outputJson = '';

  Future<void> _loadJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {

      Uint8List bytes = result.files.single.bytes!;
      String jsonText = utf8.decode(bytes);
      setState(() {
        _originalJson = jsonText;
      });
    }
  }

  void _processJson() {
    if (_originalJson.isNotEmpty) {
      final decodedJson = json.decode(_originalJson);
      if (decodedJson != null && decodedJson is List && decodedJson.isNotEmpty) {
        List<dynamic> jsonList = decodedJson;
        jsonList.forEach((element) {
          print(element);
          element.removeWhere((key, value) => !_selectedFields.contains(key));
        });
        setState(() {
          _outputJson = json.encode(jsonList);
        });
      } else {
        print('Invalid JSON data.');
      }
    } else {
      print('_originalJson is empty.');
    }
  }



  void _saveOutput() {
    final bytes = Uint8List.fromList(utf8.encode(_outputJson));
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "output.json")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JSON Field Selector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _loadJson,
              child: Text('Load JSON File'),
            ),
            if (_originalJson.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Original JSON:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(_originalJson),
                    ),
                  ),
                  Text(
                    'Select fields to keep:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  for (var field in json.decode(_originalJson)[0].keys)
                    CheckboxListTile(
                      title: Text(field),
                      value: _selectedFields.contains(field),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            _selectedFields.add(field);
                          } else {
                            _selectedFields.remove(field);
                          }
                        });
                      },
                    ),
                  ElevatedButton(
                    onPressed: _processJson,
                    child: Text('Process JSON'),
                  ),
                  if (_outputJson.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          'Output JSON:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(_outputJson),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _saveOutput,
                          child: Text('Save Output'),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
