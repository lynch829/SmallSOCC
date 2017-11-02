import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Pane {
// id: sequenceDelegate
  id: listitem
  height: 65
  padding: 0
  width: seq_list_border.availableWidth-lvseq.spacing*2 /* uniform look on all sides */
  anchors.horizontalCenter: parent.horizontalCenter
  background: Rectangle {
    anchors.fill: parent; border.color: "#bbb"; radius: 5
    color: listitem.bgcolor
  }
  state: ""

  /* user props */
  property color bgcolor:          "transparent"
  property color content_fgcolor:  "black"
  property color index_fgcolor:    "gray"

  states: [
    State {
      name: "MODIFIED"
      PropertyChanges {
        target: listitem;
        content_fgcolor: "white"
        index_fgcolor: "#d9d9d9"
        bgcolor: "#a56000"
      }
    },
    State {
      name: "SELECTED"
      when: listitem.ListView.isCurrentItem
      PropertyChanges {
        target: listitem;
        content_fgcolor: "white"
        index_fgcolor: "#d9d9d9"
        bgcolor: "steelblue"
      }
      StateChangeScript {
        script: { console.log("changing to state: SELECTED") }
      }
    }
  ]

  RowLayout {
    anchors.fill: parent
    spacing: 10
    Item { /* print index and time */
      Layout.preferredHeight: listitem.height
      Layout.preferredWidth: 45
      Layout.leftMargin: lvseq.spacing + parseInt(parent.spacing/2)
      Label { /* print index */
        id: listitem_index_label
        height: parseInt(listitem.height*0.7)
        anchors.left: parent.left;
        anchors.right: parent.right
        anchors.top: parent.top
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: index;
        color: index_fgcolor
        font.pointSize: 16
      }
      Label { /* print timecode */
        id: listitem_timecode_label
        width: listitem_index_label.width
        height: listitem.height - listitem_index_label.height
        anchors.left: parent.left;
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: Number(timecode_ms/1000).toFixed(2)
        color: index_fgcolor
        font.pointSize: 9
      }
    }
    Column { /* print content */
      id: listitem_content
      Layout.fillWidth: true
      anchors.verticalCenter: parent.verticalCenter
      Text { color: content_fgcolor;
             text: "<b>couch:</b> " + Number(rot_couch_deg).toFixed(1) +
             " deg, <b>gantry:</b> " + Number(rot_gantry_deg).toFixed(1) + " deg"
      }
      Text { color: content_fgcolor; text: "<b>desc:</b>  " + description }
      Text { color: content_fgcolor; text: "<b>added:</b> " + date_created }
      Text { color: content_fgcolor; text: "<b>type:</b>  " + type }
    }
  }
  MouseArea {
    anchors.fill: parent
    onClicked: { lvseq.currentIndex = index }
  }
}
