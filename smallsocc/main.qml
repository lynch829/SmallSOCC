import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import "dynamicqml.js" as DynamicQML


ApplicationWindow {
  visible: true
  title: mainwindow_title // global property injection
  id: mainwindow
  width: 1200*sratio
  height: 900*sratio
  minimumHeight: 700*sratio
  minimumWidth: 850*sratio
  // maximumHeight: height
  // maximumWidth: width
  property color color_bgbase: "#F4F4F4"
  color: color_bgbase
  footer: QTimedText {id: "footer_status"; interval: 5000}

  // global state variables
  property bool isTreating: false

  // prompt a refresh of the SOC display using data from the currently selected SequenceItem
  // note: this will also prompt a change in HW positions to match display
  function updateSOCConfig(publishtohw) {
    if (publishtohw === undefined) { publishtohw = true; }
    if (qsequencelist.lvseq.currentIndex < 0 || SequenceListModel.rowCount() <= 0) {
      qsocdisplay.soc_display.reset();
    } else {
      var map = {};
      var extarray = SequenceListModel.data(qsequencelist.lvseq.currentIndex, 'extension_list')
      if (extarray != null) {
        for (var i=0; i<extarray.length; ++i) {
          map[i] = extarray[i];
        }
        qsocdisplay.soc_display.setExtension(map);
      }
    }
    // TODO: KLUDGE should better differentiate signals from assembly update vs leaflet update
    if (publishtohw) {
      qsocdisplay.soc_display.onLeafletReleased(-1)
    }
  }

  // startup signal/slot connections
  Component.onCompleted: {
    // deselect items when loading new list and reset display and hw
    SequenceListModel.onModelReset.connect(function() {
      qsequencelist.lvseq.currentIndex = -1;
      updateSOCConfig();
    });

    // Keep SOC Display valid on window resize - no HW changes occur
    mainwindow.onWidthChanged.connect(function() { qsocdisplay.soc_display.refresh(); });
    mainwindow.onHeightChanged.connect(function() { qsocdisplay.soc_display.refresh(); });

    // select nothing and prevent hardware from synchronizing on application launch
    qsequencelist.lvseq.currentIndex = -1;

    // keep SOC Display and HW in sync with currentIndex in listview
    qsequencelist.lvseq.onCurrentItemChanged.connect(updateSOCConfig);
  }

  ColumnLayout {
    /* split into two horizontal control containers */
    id: controls_container
    anchors.fill: parent
    anchors.margins: 10
    anchors.bottomMargin: 0
    spacing: controls_container.anchors.margins
    RowLayout {
      id: upper_half
      spacing: controls_container.anchors.margins
      Layout.fillWidth: true

      QSOCDisplay { /* QLeafletAssembly + controls */
        id: qsocdisplay
        Layout.alignment: Qt.AlignTop
        Layout.fillHeight: true
        Layout.minimumWidth: 250*sratio
        Layout.maximumWidth: 500*sratio
        enabled: !isTreating
      }
      QSequenceList { /* ListView + Buttons */
        id: qsequencelist
        Layout.fillWidth: true
      }
    }

    Pane { /* filedialog controls */
      id: bottom_frame
      Layout.maximumHeight: 200*sratio
      Layout.minimumHeight: 40*sratio
      Layout.fillWidth: true
      enabled: !isTreating
      background: QDebugBorder {}

      RowLayout {
        anchors.fill: parent

        TextInput {
          id: field_json_path
          Layout.fillWidth: true
          readOnly: true
          text: "Load a treatment plan..."
        }
        Button { /* Load JSON */
          text: "Load"
          Layout.alignment: Qt.AlignRight
          onClicked: {
            var d = DynamicQML.createDynamicObject(mainwindow, "QFileDialog.qml", {"intent": "load"});
            d.onAccepted.connect( function() {
              if (SequenceListModel.readFromJson(d.path)) {
                field_json_path.text = d.path;
                var msg = "Sequence list loaded from \""+d.path+"\"";
                footer_status.text = msg;
                field_json_path.text = d.path;
              }
              d.destroy(); /* cleanup */
            });
            d.open();
          }
        }
        Button { /* Save JSON */
          text: "Save"
          Layout.alignment: Qt.AlignRight
          onClicked:{
            var d = DynamicQML.createDynamicObject(mainwindow, "QFileDialog.qml", {"intent": "save"});
            d.onAccepted.connect( function() {
              if (SequenceListModel.writeToJson(d.path)) {
                var msg = "Sequence list saved to \""+d.path+"\"";
                footer_status.text = msg;
                field_json_path.text = d.path;
              }
              d.destroy(); /* cleanup */
            });
            d.open();
          }
        }
      }

    }
  }
}
