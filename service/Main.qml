import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  property var pluginApi

  readonly property string scriptPath: pluginApi && pluginApi.pluginDir ? pluginApi.pluginDir + "/bin/fetch-medicine.py" : (Quickshell.env("HOME") + "/.local/share/ryoku/plugins/medkit-guide/bin/fetch-medicine.py")

  property var medicines: []
  property bool loading: false
  property string lastError: ""
  property string actionMessage: ""

  function refill(name) {
    root.actionMessage = "Refilling " + name + "..."
    refillProc.command = ["/home/hatem/medkit/bin/medkit", "--refill", name]
    refillProc.running = true
  }

  function refillAll() {
    root.actionMessage = "Refilling all low..."
    refillProc.command = ["/home/hatem/medkit/bin/medkit", "--refill"]
    refillProc.running = true
  }

  function loadMedicines() {
    root.loading = true
    root.lastError = ""
    fetchProcess.command = ["python3", root.scriptPath]
    fetchProcess.running = true
  }

  Process {
    id: fetchProcess
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var data = JSON.parse(text)
          if (data.medicines) {
            var meds = []
            for (var key in data.medicines) {
              meds.push(data.medicines[key])
            }
            root.medicines = meds
          }
          if (data.errors && data.errors.length > 0) {
            root.lastError = data.errors.join("; ")
          }
        } catch (e) {
          root.lastError = "Failed to parse medicine data: " + String(e)
        }
        root.loading = false
      }
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (text && text.trim()) {
          root.lastError = text.trim()
        }
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0 && !root.lastError) {
        root.lastError = "Failed to fetch medicine details (exit " + exitCode + ")"
      }
      root.loading = false
    }
  }

  function refresh() {
    loadMedicines()
  }

  function getMedicineByName(name) {
    for (var i = 0; i < root.medicines.length; i++) {
      if (root.medicines[i].name === name) return root.medicines[i]
    }
    return null
  }

  Process {
    id: refillProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        if (text && text.trim()) {
          root.actionMessage = text.trim()
        }
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) {
        root.actionMessage = "Refill failed"
      }
      // Refresh medicine data after refill
      Qt.callLater(root.loadMedicines)
    }
  }

  Component.onCompleted: {
    loadMedicines()
  }
}
