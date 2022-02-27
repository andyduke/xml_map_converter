import 'dart:convert';
import 'dart:io';
import 'package:xml_map_converter/xml_map_converter.dart';

void displayUsage() {
  print('''
Usage: echo <content> | converter_tool --to-json|--to-xml
''');
}

String? readInputSync({Encoding encoding = systemEncoding}) {
  final input = <int>[];
  while (true) {
    int byte = stdin.readByteSync();
    if (byte < 0) {
      if (input.isEmpty) return null;
      break;
    }
    input.add(byte);
  }
  return encoding.decode(input);
}

void main(List<String> arguments) async {
  String? mode;
  for (var arg in arguments) {
    if (arg == '--to-json') {
      mode = 'xml2json';
    } else if (arg == '--to-xml') {
      mode = 'json2xml';
    }
  }

  if (mode == null) {
    displayUsage();
    exit(64);
  }

  final data = readInputSync() ?? '';

  // print(data);

  switch (mode) {
    case 'xml2json':
      final converter1 = Xml2Map(data);
      final result = await converter1.transform();
      final encoder = JsonEncoder.withIndent(
          ' ' * 2, (dynamic object) => object.toString());
      final json = encoder.convert(result);
      print(json);
      break;

    case 'json2xml':
      final jsonData = json.decode(data);
      final converter2 = Map2Xml(jsonData);
      final xml = converter2.transform();
      print(xml);
      break;
  }
}
