import 'package:xml_map_converter/src/types.dart';

///
/// Credits to Stefan Goessner/2006 (http://goessner.net/)
///
class Map2Xml {
  static const defaultXmlPrefix = '<?xml version="1.0" encoding="UTF-8"?>';

  final DataMap map;
  final int indent;
  final String eol;

  final String xmlPrefix;
  final String attrPrefix;
  final String textNode;
  final String cdataNode;

  Map2Xml(
    this.map, {
    this.indent = defaultIndent,
    this.eol = "\r\n",
    this.xmlPrefix = defaultXmlPrefix,
    this.attrPrefix = defaultAttrPrefix,
    this.textNode = defaultTextNode,
    this.cdataNode = defaultCdataNode,
  });

  String transform() {
    var xml = StringBuffer();

    if (xmlPrefix.isNotEmpty) {
      xml.write(xmlPrefix);
    }

    for (var entry in map.entries) {
      xml.write(_toXml(entry.value, entry.key, ''));
    }

    return xml.toString().trim();
  }

  String _toXml(dynamic data, String name, String indentStr) {
    var xml = '';

    // Array
    if (data is List) {
      for (var i = 0, len = data.length; i < len; i++) {
        xml += _toXml(data[i], name, indentStr);
      }
    } else

    // Map
    if (data is Map) {
      var hasChild = false;

      // Build tag with attributes
      xml += eol + indentStr + '<$name';
      for (var attr in data.entries) {
        if (attr.key is! String) continue;
        if (attr.key.startsWith(attrPrefix)) {
          xml += ' ${attr.key.substring(attrPrefix.length)}="${attr.value}"';
        } else {
          hasChild = true;
        }
      }
      xml += hasChild ? '>' : '/>';

      // Build children
      if (hasChild) {
        var hasChildNodes = false;
        for (var node in data.entries) {
          if (node.key is! String) continue;
          if (node.key == textNode) {
            xml += node.value;
          } else if (node.key == cdataNode) {
            xml += eol +
                indentStr +
                _newIndent +
                '<![CDATA[${node.value}]]>' +
                eol;
          } else if (!node.key.startsWith(attrPrefix)) {
            final children =
                _toXml(node.value, node.key, indentStr + _newIndent);
            if (children.isNotEmpty) {
              hasChildNodes = true;
            }
            xml += children;
          }
        }

        // Close tag
        if (hasChildNodes) xml += eol;
        xml += (xml.endsWith(eol) ? indentStr : '') + '</$name>';
      }
    } else {
      // Other types
      xml += eol + indentStr + '<$name>$data</$name>';
    }

    return xml;
  }

  String get _newIndent => ''.padLeft(indent);
}
