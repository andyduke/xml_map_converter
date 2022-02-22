# XML Map Converter

XML to Dart map converter and vice versa.

Inspired by the work of [Stefan Goessner](https://www.xml.com/pub/a/2006/05/31/converting-between-xml-and-json.html).

The package contains two classes, first for converting XML text to dart Maps, and second for converting a dart Map to XML text.

## Xml2Map

Converts XML text to dart Map structures.

Tag names are converted to keys in the Map, tag values and attributes are converted to values in the Map.

For example, the following xml...

```xml
<users>
  <user id="1">
    <name>John</name>
    <surname>Doe</surname>
  </user>
  <user id="2">
    <name>Richard</name>
    <surname>Roe</surname>
  </users>
</users>
```

will be converted to a structure:

```dart
{
  "users": {
    "user": [
      {
        "@id": "1",
        "name": "John",
        "surname": "Doe"
      },
      {
        "@id": "2",
        "name": "Richard",
        "surname": "Roe"
      }
    ]
  }
}
```

### Attributes

XML attributes are turned into keys prefixed with `@`, for example:

```xml
<record id="1"/>
```

```dart
{
  "record": {
    "@id": "1"
  }
}
```

### Node content

The text content of the xml node is turned into a value in the Map...

```xml
<record>Record 1</record>
```

```dart
{
  "record": "Record 1"
}
```

...but if the Map already has attributes or nested values, then the text content is written to the `#text` key: 

```xml
<record id="1">Record 1</record>
```

```dart
{
  "record": {
    "@id": "1",
    "#text": "Record 1"
  }
}
```

### CDATA

The CDATA content of the xml node is written to the `#cdata` key:

```xml
<record id="1">
  <![CDATA
    Record 1
  ]]>
</record>
```

```dart
{
  "record": {
    "@id": "1",
    "#cdata": "
    Record 1
  "
  }
}
```

### Tag list

Multiple tags with the same name are combined into a list:

```xml
<records>
  <record id="1">Record 1</record>
  <record id="1">Record 1</record>
  <total>2 records</total>
</records>
```

```dart
{
  "records": {
    "record": [
      {
        "@id": "1",
        "#text": "Record 1"
      },
      {
        "@id": "1",
        "#text": "Record 1"
      }
    ],
    "total": "2 records"
  }
}
```

## Map2Xml

Converts dart Map structures to XML text.

Converts a dart Map to XML text, turning keys into tags, values into tag content and child tags, @ prefixed keys into tag attributes, [see above for details](#xml2map).
