import QtQuick 2.0
import QtLocation 5.6
import QtPositioning 5.3

MapQuickItem{
    id: plane
    property string pilotName;
    property int bearing: 0;

    visible: true

    anchorPoint.x: image.width/2
    anchorPoint.y: image.height/2
    Behavior on coordinate {

        CoordinateAnimation{
            duration: 200
            easing.type: Easing.Linear
        }
    }

    sourceItem: Grid {

        columns: 1
        Grid {
            Image {
                id: image
                width: 40
                height : width
                rotation: bearing
                source: "qrc:/icon/airplane.png"
            }
            Rectangle {
                id: bubble
                color: "lightblue"
                border.width: 1
                width: text.width * 1.3
                height: text.height * 1.3
                radius: 5
                Text {
                    id: text
                    anchors.centerIn: parent
                    text: pilotName
                }
            }
        }

    }
}
