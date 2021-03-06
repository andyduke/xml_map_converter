import 'package:xmlstream/xmlstream.dart';
import 'package:xml_map_converter/src/types.dart';
import 'package:xml_map_converter/src/consts.dart';

class _NodeInfo {
  final String? name;
  final dynamic value;

  _NodeInfo(this.name, this.value);
}

/// Class for converting XML to Dart Maps
///
/// - Tag names are converted to keys in the Map, tag values and attributes are converted to values in the Map.
/// - XML attributes are turned into keys prefixed with `@`.
/// - The text content of the xml node is turned into a value in the Map, but if the Map already has attributes or nested values, then the text content is written to the `#text` key.
/// - The CDATA content of the xml node is written to the `#cdata` key.
/// - Multiple tags with the same name are combined into a list.
///
/// See also: https://www.xml.com/pub/a/2006/05/31/converting-between-xml-and-json.html
class Xml2Map {
  late final XmlStreamer _xmlStreamer;

  /// XML attribute prefix in JSON
  final String attrPrefix;

  /// Text property name in JSON
  final String textNode;

  /// CDATA property name in JSON
  final String cdataNode;

  DataMap? _node;
  String? _nodeName;

  final List<_NodeInfo> _nodeStack = [];

  /// Creates a XML to Dart Maps conversion object
  Xml2Map(
    String xml, {
    this.attrPrefix = defaultAttrPrefix,
    this.textNode = defaultTextNode,
    this.cdataNode = defaultCdataNode,
  }) {
    _xmlStreamer = XmlStreamer(xml);
  }

  /// Converts XML to Dart Maps
  Future<DataMap?> transform() async {
    await _xmlStreamer.read().listen(_onData).asFuture();
    return _node;
  }

  void _pushNode(String name) {
    _nodeStack.add(_NodeInfo(_nodeName, _node));

    final newNodeElement = <String, dynamic>{};
    _node = newNodeElement;
    _nodeName = name;
  }

  void _pushDocument() {
    _pushNode('document');
  }

  void _pushTagNode(String name) {
    _pushNode(name);
  }

  void _popNode() {
    _NodeInfo? parentInfo;
    if (_node != null && _nodeName != null) {
      parentInfo = _nodeStack.isNotEmpty ? _nodeStack.removeLast() : null;
      if (parentInfo != null) {
        dynamic value;
        if (_node is Map &&
            _node!.keys.length == 1 &&
            _node!.keys.first == textNode) {
          // Unpack single text node
          value = _node![textNode];
        } else {
          value = _node;
        }

        if (parentInfo.value!.containsKey(_nodeName!)) {
          // Convert to list
          if (parentInfo.value![_nodeName!] is! List) {
            parentInfo.value![_nodeName!] = [parentInfo.value![_nodeName!]];
          }

          parentInfo.value![_nodeName!].add(value);
        } else {
          parentInfo.value![_nodeName!] = value;
        }
      }
    }

    _nodeName = parentInfo?.name;
    _node = parentInfo?.value;
  }

  void _onData(XmlEvent event) {
    switch (event.state) {
      case XmlState.StartDocument:
        _pushDocument();
        break;

      case XmlState.EndDocument:
        break;

      case XmlState.Open:
        _pushTagNode(event.value!);
        break;

      case XmlState.Closed:
        _popNode();
        break;

      case XmlState.Attribute:
        _node?[attrPrefix + event.key!] = event.value!.trim();
        break;

      case XmlState.Text:
        final textValue = event.value?.trim();
        if (textValue != null && textValue.isNotEmpty) {
          _node?[textNode] = textValue;
        }
        break;

      case XmlState.CDATA:
        final cdataValue = event.value;
        if (cdataValue != null && cdataValue.isNotEmpty) {
          _node?[cdataNode] = cdataValue;
        }
        break;

      case XmlState.Top:
      case XmlState.Namespace:
      case XmlState.Comment:
        break;
    }
  }
}
