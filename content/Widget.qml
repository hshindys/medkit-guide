import QtQuick
import Ryoku.PluginKit

Item {
  id: root
  property var pluginApi
  property bool isGlyph: true
  property real s: 1
  property real glyphW: 22
  property real glyphH: 22

  Text {
    anchors.centerIn: parent
    text: "M"
    font.pixelSize: 16 * root.s
    color: "#ff0000"
  }
}
