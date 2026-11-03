import QtQuick
import Ryoku.PluginKit

Item {
  id: root
  property var pluginApi
  property bool isGlyph: true
  property real s: 1
  property real glyphW: 22
  property real glyphH: 22

  readonly property var service: pluginApi && pluginApi.mainInstance ? pluginApi.mainInstance : null

  Text {
    anchors.centerIn: parent
    text: "💊"
    font.pixelSize: 16 * root.s
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.pluginApi && root.pluginApi.togglePanel()
  }
}
