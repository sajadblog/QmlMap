import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtLocation 5.6
import QtPositioning 5.3
import "qrc:/functions/jsonParser.js" as Parser

Item {

    property int currentTools: 0
    property bool firstCLick: true
    property var xName: "longitude"
    property var yName: "latitude"
    property int  uuid: 100

    signal newRegion(string geometry)

    visible: true

    id : mainwindow
    width: 500
    height: 500

    ListModel{
        id : regionModel
    }
    ListModel{
        id : targetModel
        ListElement{
            uid : 10
            lati:26
            longi:56
            heading: 0
        }
    }

    ListModel{
        id : toolsListModel
        ListElement {
            name: "circle"
            icon : "qrc:/icon/Steren_circle.png"
            type: 1
        }
        ListElement {
            name: "rectangle"
            icon : "qrc:/icon/Steren_rectangle.png"
            type: 2
        }
        //                ListElement {
        //                    name: "polyline"
        //                    icon : "qrc:/icon/Steren_rectangle.png"
        //                    type: 3
        //                }
        ListElement {
            name: "polygon"
            icon : "qrc:/icon/Steren_Polygone.png"
            type: 4
        }
    }


    Rectangle{
        property int toolboxMargin: worldMap.width / 200
        id : toolsBox
        y : parent.height / 2 - height /2
        width: worldMap.width / 20
        height: toolsListModel.count * worldMap.width / 20
        z: worldMap.z + 1
        opacity:  0.75
        radius : 10
        color:  "darkgray"
        ListView {
            id : toolsBoxListView
            anchors.fill: parent
            anchors.margins: toolsBox.toolboxMargin
            spacing: toolsBox.toolboxMargin
            model: toolsListModel
            orientation : ListView.Vertical

            delegate: Button{
                width : toolsBox.width - toolsBox.toolboxMargin * 2
                height: width
                z : toolsBox.z + 1

                Image {
                    id: buttonImage
                    anchors.fill: parent
                    source: icon
                }
                onClicked: {
                    currentTools = type;
                    mapMouseArea.cursorShape = Qt.CrossCursor
                    firstCLick = true;
                    sampleCircle.visible = false
                    sampleRectangle.visible = false
                    samplePolyline.visible = false
                }
            }
        }
    }

    Plugin {
        id: somePlugin
        name: "osm"
    }

    Timer {
        interval: 500; running: true; repeat: true
        onTriggered: {
            mainwindow.updateTarget(targetModel.get(0)["uid"],
                                    targetModel.get(0)["lati"] + 0.1,
                                    targetModel.get(0)["longi"] + 0.1)
        }
    }

    Map
    {
        id: worldMap
        antialiasing: true
        anchors.fill: parent

        plugin: somePlugin

        center {
            latitude: 26
            longitude: 56
        }
        gesture.enabled: true

        MapItemView {
            model: targetModel
            delegate: Plane{
                pilotName: uid
                coordinate: QtPositioning.coordinate(lati,longi)
                bearing:  heading

            }
        }

        MapItemView {
            model: regionModel
            delegate: MapPolygon{
                path: modelPath.path
                antialiasing: true
                color: 'red'
                opacity: 0.3
                border.width: 3
                border.color: 'gray'
            }
        }

        MapCircle {
            id : sampleCircle
            antialiasing: true
            color: 'transparent'
            border.width: 3
            border.color: 'red'
        }
        MapRectangle {
            id : sampleRectangle
            antialiasing: true
            color: 'transparent'
            border.width: 3
            border.color: 'blue'
        }
        MapPolyline{
            id : samplePolyline
            antialiasing: true
            line.width: 3
            line.color: 'green'
        }

        MouseArea {
            id: mapMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: {
                if(currentTools == 0)
                    return;
                if (mouse.button == Qt.RightButton)
                {
                    cursorShape = Qt.ArrowCursor;
                    currentTools = 0;
                    return;
                }
                if(firstCLick)
                    samplePolyline.path = []

                switch(currentTools)
                {
                case 1:
                {
                    if(firstCLick)
                    {
                        sampleCircle.center = worldMap.toCoordinate(Qt.point(mouse.x,mouse.y));
                        firstCLick = false;
                        sampleCircle.visible = true
                        return;
                    }else
                    {
                        firstCLick = true
                        sampleCircle.visible = false
                        samplePolyline.visible = false

                        var circleList = [];
                        for(var i = 0 ;i < 360 ; i +=3)
                        {
                            var circleNodePosition={};
                            var tmpCoordinate = sampleCircle.center.atDistanceAndAzimuth(sampleCircle.radius,i)
                            circleNodePosition[yName] = tmpCoordinate.latitude;
                            circleNodePosition[xName] = tmpCoordinate.longitude;
                            circleList.push(circleNodePosition);
                            samplePolyline.addCoordinate(tmpCoordinate);
                        }
                        var circleListCompelete = {points: circleList};

                        var circleJsonString = JSON.stringify(circleListCompelete);

                        newRegion(circleJsonString);

                        var aaa = {};
                        aaa.path = samplePolyline.path;
                        regionModel.append({"id":getUUID(),"modelPath":aaa})


                        //                        circleModel.append({"modelRadius":sampleCircle.radius,"modelLatitude":sampleCircle.center.latitude,"modelLongitude":sampleCircle.center.longitude})

                        return;
                    }
                }

                case 2 :
                {
                    if(firstCLick)
                    {
                        sampleRectangle.topLeft = worldMap.toCoordinate(Qt.point(mouse.x,mouse.y));
                        firstCLick = false;
                        sampleRectangle.visible = true
                        return;
                    }else
                    {
                        firstCLick = true
                        sampleRectangle.visible = false
                        samplePolyline.visible = false

                        var rectangleList = [];

                        var rectangleNodePosition={};

                        var longiiiiii = sampleRectangle.topLeft.longitude

                        tmpCoordinate = sampleRectangle.topLeft
                        rectangleNodePosition[yName] = tmpCoordinate.latitude;
                        rectangleNodePosition[xName] = tmpCoordinate.longitude;
                        rectangleList.push(rectangleNodePosition);
                        samplePolyline.addCoordinate(tmpCoordinate)

                        tmpCoordinate.longitude = sampleRectangle.bottomRight.longitude
                        rectangleNodePosition[yName] = tmpCoordinate.latitude;
                        rectangleNodePosition[xName] = tmpCoordinate.longitude;
                        rectangleList.push(rectangleNodePosition);
                        samplePolyline.addCoordinate(tmpCoordinate)

                        tmpCoordinate = sampleRectangle.bottomRight
                        rectangleNodePosition[yName] = tmpCoordinate.latitude;
                        rectangleNodePosition[xName] = tmpCoordinate.longitude;
                        rectangleList.push(rectangleNodePosition);
                        samplePolyline.addCoordinate(tmpCoordinate)

                        tmpCoordinate.longitude = longiiiiii
                        rectangleNodePosition[yName] = tmpCoordinate.latitude;
                        rectangleNodePosition[xName] = tmpCoordinate.longitude;
                        rectangleList.push(rectangleNodePosition);
                        samplePolyline.addCoordinate(tmpCoordinate)  //جهت افزودن نقطه جدید به چند ضلعی با مختصات جهانی

                        var rectangleListCompelete = {points: rectangleList};

                        var rectangleJsonString = JSON.stringify(rectangleListCompelete);

                        newRegion(rectangleJsonString);

                        aaa = {};
                        aaa.path = samplePolyline.path;
                        regionModel.append({"id":getUUID(),"modelPath":aaa})


                        return;
                    }

                }
                case 3 :
                case 4 :
                {
                    samplePolyline.visible = true
                    if(firstCLick)
                    {
                        samplePolyline.path = []

                        samplePolyline.addCoordinate(worldMap.toCoordinate(Qt.point(mouse.x,mouse.y)));
                        samplePolyline.addCoordinate(worldMap.toCoordinate(Qt.point(mouse.x,mouse.y)));
                        firstCLick = false;
                        return;
                    }else
                    {
                        samplePolyline.addCoordinate(worldMap.toCoordinate(Qt.point(mouse.x,mouse.y)));
                        return;
                    }

                }
                default:
                {
                    break;
                }
                }
            }

            onDoubleClicked: {
                if(currentTools == 0)
                    return;
                switch(currentTools)
                {
                case 3 :
                {
                    if(!firstCLick)
                    {
                        firstCLick = true;
                    }
                    break;
                }
                case 4 :
                {
                    if(!firstCLick)
                    {
                        var polygonList = [];
                        if(samplePolyline.pathLength() < 3)
                            return;

                        for(var i = 0 ; i < samplePolyline.pathLength() - 2 ; i++)
                        {
                            var polygonNodePosition={};
                            polygonNodePosition[yName] = samplePolyline.coordinateAt(i).longitude;
                            polygonNodePosition[xName] = samplePolyline.coordinateAt(i).latitude;
                            polygonList.push(polygonNodePosition);
                        }
                        var polygonListCompelete = {points: polygonList};

                        var polygonJsonString = JSON.stringify(polygonListCompelete);

                        newRegion(polygonJsonString);

                        samplePolyline.visible = false
                        firstCLick = true;

                        var aaa = {};
                        aaa.path = samplePolyline.path;

                        regionModel.append({"id":getUUID(),"modelPath":aaa})
                    }
                    break;
                }
                default:
                {
                    break;
                }
                }
            }

            onMouseXChanged: {
                switch(currentTools)
                {
                case 1:
                {
                    if(!firstCLick)
                        sampleCircle.radius = sampleCircle.center.distanceTo(worldMap.toCoordinate(Qt.point(mouse.x,mouse.y)));
                    break;
                }


                case 2:
                {
                    if(!firstCLick)
                        sampleRectangle.bottomRight = worldMap.toCoordinate(Qt.point(mouse.x,mouse.y));
                    break;
                }
                case 3:
                case 4:
                {
                    if(!firstCLick)
                        samplePolyline.replaceCoordinate(samplePolyline.pathLength() -1  ,worldMap.toCoordinate(Qt.point(mouse.x,mouse.y)));
                    break;
                }
                default:
                {
                    break;
                }
                }
            }
        }
        //        onZoomLevelChanged: {
        //             var valuefirstCoordinate = worldMap.toCoordinate(Qt.point(0,0));
        //            var valueSecondCoordinate = worldMap.toCoordinate(Qt.point(50,0))
        //            var valueNodeRadius = valuefirstCoordinate.distanceTo(valueSecondCoordinate)
        //            console.error(valueNodeRadius)

        //            if (circleModel.count > 0)
        //            {
        //                for (var i = 0; i < circleModel.count; ++i)
        //                {
        //                    circleModel.get(i)["nodeRadius"] = valueNodeRadius
        //                }
        //            }
        //        }


    }

    function updateTarget(_id,_lat,_long)
    {
        var indexNumber = find(_id)
        if(indexNumber === -1){
            targetModel.append({"uid":_id,"lati":_lat,"longi":_long})
        }
        else{
            var _heading = QtPositioning.coordinate(targetModel.get(indexNumber)["lati"],
                                                    targetModel.get(indexNumber)["longi"]).azimuthTo(QtPositioning.coordinate(_lat,_long))
            targetModel.set(indexNumber,{"uid":_id,"lati":_lat,"longi":_long ,"heading":_heading})
        }

        //sampleRectangle.topLeft = ;
        //sampleRectangle.bottomRight = ;

    }

    function find(_id)
    {
        if (targetModel.count > 0)
        {
            for (var i = 0; i < targetModel.count; ++i)
            {
                if (targetModel.get(i)["uid"] === _id)
                {
                    return i;
                }
                return -1 ;
            }
            return -1 ;
        }
    }

    function getUUID()
    {
        return uuid++;
    }
}
