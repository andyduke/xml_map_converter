import 'package:xml_map_converter/xml_map_converter.dart';
import 'package:test/test.dart';

void main() {
  test('Xml2Map', () async {
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

    final converter = Xml2Map(xml);
    final data = await converter.transform();

    final expectedMap = {
      'root': {
        'items': {
          'text': 'Plain text',
          'letter': ['A', 'B'],
          'empty': {},
          'group': {
            'item': [
              {
                '@name': 'caption',
                '#text': 'Caption 1',
              },
              {
                '@name': 'url',
                '#text': 'https://www.google.com',
              },
            ],
          },
          'item': [
            {
              '@type': 'text',
              '#text': 'Text',
            },
            {
              '@type': 'sample',
              '#text': 'Item 2',
            },
          ],
          'data': {
            '@name': 'test',
            '#cdata': '''

        cdata
      ''',
          },
        },
      },
    };

    expect(data, equals(expectedMap));
  });

  test('Map2Xml', () {
    final map = {
      'root': {
        'items': {
          'text': 'Plain text',
          'letter': ['A', 'B'],
          'empty': {},
          'group': {
            'item': [
              {
                '@name': 'caption',
                '#text': 'Caption 1',
              },
              {
                '@name': 'url',
                '#text': 'https://www.google.com',
              },
            ],
          },
          'item': [
            {
              '@type': 'text',
              '#text': 'Text',
            },
            {
              '@type': 'sample',
              '#text': 'Item 2',
            },
          ],
          'data': {
            '@name': 'test',
            '#cdata': '''

        cdata
      ''',
          },
        },
      },
    };

    final converter = Map2Xml(map, eol: '\n');
    final xml = converter.transform();

    final expectedXml = '''<?xml version="1.0" encoding="UTF-8"?>
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
    <item type="text">Text</item>
    <item type="sample">Item 2</item>
    <data name="test">
      <![CDATA[
        cdata
      ]]>
    </data>
  </items>
</root>''';

    expect(xml, expectedXml);
  });
}
