import 'package:xmlstream/xmlstream.dart';
import 'package:xml_map_converter/src/types.dart';

class NodeInfo {
  final String? name;
  final dynamic value;

  NodeInfo(this.name, this.value);
}

class Xml2Map {
  late final XmlStreamer xmlStreamer;

  final String attrPrefix;
  final String textNode;
  final String cdataNode;

  DataMap? _node;
  String? _nodeName;

  final List<NodeInfo> _nodeStack = [];

  Xml2Map(
    String xml, {
    this.attrPrefix = defaultAttrPrefix,
    this.textNode = defaultTextNode,
    this.cdataNode = defaultCdataNode,
  }) {
    xmlStreamer = XmlStreamer(xml);
  }

  Future<DataMap?> transform() async {
    await xmlStreamer.read().listen(_onData).asFuture();
    return _node;
  }

  void _pushNode(String name) {
    _nodeStack.add(NodeInfo(_nodeName, _node));

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
    NodeInfo? parentInfo;
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
