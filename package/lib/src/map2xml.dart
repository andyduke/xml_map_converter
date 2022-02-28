import 'package:xml_map_converter/src/types.dart';
import 'package:xml_map_converter/src/consts.dart';

/// Class for converting Dart Maps to XML
///
/// Credits to Stefan Goessner/2006 (http://goessner.net/)
///
/// Keys in the Map are converted to child tag names, keys prefixed with @ are converted to tag attributes.
/// The `#text` keys are converted to the text values of the tags.
/// The `#cdata` keys are converted to text values of CDATA tags.
/// Lists are converted to multiple tags with the same name.
///
/// See also: https://www.xml.com/pub/a/2006/05/31/converting-between-xml-and-json.html
class Map2Xml {
  /// XML Processing Instruction by default
  static const defaultXmlPrefix = '<?xml version="1.0" encoding="UTF-8"?>';

  /// Dart map to convert
  final DataMap map;

  /// Indentation for XML Formatting
  final int indent;

  /// Line ending
  final String eol;

  /// XML Processing Instruction
  final String xmlPrefix;

  /// XML attribute prefix in JSON
  final String attrPrefix;

  /// Text property name in JSON
  final String textNode;

  /// CDATA property name in JSON
  final String cdataNode;

  /// Creates a Dart Maps to XML conversion object
  Map2Xml(
    this.map, {
    this.indent = defaultIndent,
    this.eol = "\r\n",
    this.xmlPrefix = defaultXmlPrefix,
    this.attrPrefix = defaultAttrPrefix,
    this.textNode = defaultTextNode,
    this.cdataNode = defaultCdataNode,
  });

  /// Converts Dart Maps to XML
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
