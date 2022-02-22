import 'package:xml_map_converter/xml_map_converter.dart';

void main() async {
  final xml = '''<?xml version="1.0" encoding="UTF-8"?>
<root>
  <items>
    <text>Plain text</text>
    <letter>A</letter>
    <letter>B</letter>
    <empty/>
    <group>
      <item name="caption">Caption 1</item>
      <item name="url">https://www.google.com</item>
    </group>
    <item type="text">
      Text
    </item>
    <data name="test">
      <![CDATA[
        cdata
      ]]>
    </data>
    <item type="sample">
      Item 2
    </item>
  </items>
</root>''';

  final converter1 = Xml2Map(xml);
  final data = await converter1.transform();

  final converter2 = Map2Xml(data!);
  final newXml = converter2.transform();

  print('$xml\n');
  print('$data\n');
  print('$newXml\n');
}
