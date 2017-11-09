import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Pane {
  id: seqdelegate
  height: 65
  padding: 0
  width: seq_list_border.availableWidth-lvseq.spacing*2 /* uniform look on all sides */
  anchors.horizontalCenter: parent.horizontalCenter
  background: Rectangle {
    anchors.fill: parent; border.color: "#bbb"; radius: 5
    color: seqdelegate.bgcolor
  }
  state: ""

  /* user props */
  property color bgcolor:          "transparent"
  property color content_fgcolor:  "black"
  property color index_fgcolor:    "gray"
  property bool  is_modified:      false

  signal modified; // indicates data that hasn't been saved to file
  signal saved;    // indicates that data has been saved to file

  // get model which stores all items for attached view
  function getModel() { return seqdelegate.ListView.view.model; }

  // gets SequenceItem associated with this delegate
  function getItem() {
    // console.debug("getItem("+index+")");
    return getModel().getItem(index);
  }

  // get/set data on SequenceItem associated with this delegate
  function getData() {
    return getItem().get();
  }
  function setData(datamap) {
    var model = getModel();
    if (getItem(index).set(datamap)) {
      var modelindex = model.index(index, 0);
      model.dataChanged(modelindex, modelindex); // redraw delegate
      modified();
    } else {
      console.debug('failed to set data on item: '+index);
      return false;
    }
    return true;
  }

  // visually indicate that this data is unsaved exists only in gui state
  onModified: function() {
    is_modified = true;
  }

  states: [
    State {
      name: "MODIFIED"
      when: is_modified && !seqdelegate.ListView.isCurrentItem
      PropertyChanges {
        target: seqdelegate
        content_fgcolor: "white"
        index_fgcolor: "#d9d9d9"
        bgcolor: "#a56000"
      }
    },
    State {
      name: "SELECTED"
      when: seqdelegate.ListView.isCurrentItem && !is_modified
      PropertyChanges {
        target: seqdelegate
        content_fgcolor: "white"
        index_fgcolor: "#d9d9d9"
        bgcolor: "steelblue"
      }
    },
    State {
      name: "MOD_SELECT"
      when: seqdelegate.ListView.isCurrentItem && is_modified
      PropertyChanges {
        target: seqdelegate
        content_fgcolor: "white"
        index_fgcolor: "#d9d9d9"
        bgcolor: "#c99000"
      }
    }
  ]

  RowLayout {
    anchors.fill: parent
    spacing: 10
    Item { /* print index and time */
      Layout.preferredHeight: seqdelegate.height
      Layout.preferredWidth: 45
      Layout.leftMargin: lvseq.spacing + parseInt(parent.spacing/2)
      Label { /* print index */
        id: seqdelegate_index_label
        height: parseInt(seqdelegate.height*0.7)
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
        id: seqdelegate_timecode_label
        width: seqdelegate_index_label.width
        height: seqdelegate.height - seqdelegate_index_label.height
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
      id: seqdelegate_content
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