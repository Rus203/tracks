import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 720
    minimumWidth: 820
    minimumHeight: 520
    title: "TrackViewer"

    readonly property color c_bg:       "#0f172a"
    readonly property color c_surface:  "#1e293b"
    readonly property color c_border:   "#334155"
    readonly property color c_accent:   "#0ea5e9"
    readonly property color c_text:     "#f1f5f9"
    readonly property color c_muted:    "#64748b"
    readonly property color c_selected: "#0c4a6e"
    readonly property color c_hover:    "#1e3a50"
    readonly property color c_track:    "#f97316"
    readonly property color c_start:    "#22c55e"
    readonly property color c_error:    "#ef4444"

    Plugin {
        id: mapPlugin
        name: "osm"
        PluginParameter { name: "osm.mapping.providersrepository.disabled"; value: "true" }
        PluginParameter { name: "osm.mapping.custom.host"; value: "https://tile.openstreetmap.org/" }
    }

    // ── Error modal ──────────────────────────────────────────────────────────
    Rectangle {
        id: errorModal
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        z: 100
        visible: false

        MouseArea { anchors.fill: parent }

        Rectangle {
            anchors.centerIn: parent
            width: 380
            height: 170
            radius: 10
            color: root.c_surface
            border.color: root.c_error
            border.width: 1

            Column {
                anchors { fill: parent; margins: 24 }
                spacing: 14

                Row {
                    spacing: 10
                    Canvas {
                        width: 20; height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, 20, 20)
                            ctx.strokeStyle = root.c_error
                            ctx.lineWidth = 2
                            ctx.lineCap = "round"
                            ctx.beginPath()
                            ctx.moveTo(10, 3); ctx.lineTo(10, 13)
                            ctx.moveTo(10, 16); ctx.lineTo(10, 17)
                            ctx.stroke()
                            ctx.beginPath()
                            ctx.moveTo(2, 18); ctx.lineTo(10, 3); ctx.lineTo(18, 18); ctx.closePath()
                            ctx.strokeStyle = root.c_error
                            ctx.stroke()
                        }
                    }
                    Text {
                        text: "Corrupted track file"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: root.c_text
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    id: errorDetail
                    text: ""
                    font.pixelSize: 12
                    color: root.c_muted
                    wrapMode: Text.WordWrap
                    width: 332
                }

                Rectangle {
                    width: 72; height: 28; radius: 5
                    color: closeBtn.containsMouse ? root.c_error : Qt.rgba(0.94, 0.27, 0.27, 0.12)
                    border.color: root.c_error; border.width: 1
                    anchors.right: parent.right
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text { anchors.centerIn: parent; text: "Close"; font.pixelSize: 12; color: root.c_text }
                    MouseArea {
                        id: closeBtn; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: errorModal.visible = false
                    }
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Left panel ───────────────────────────────────────────────────────
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: root.c_surface

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    color: root.c_bg

                    RowLayout {
                        anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                        spacing: 8

                        // Route icon
                        Canvas {
                            width: 16; height: 16
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, 16, 16)
                                ctx.strokeStyle = root.c_accent
                                ctx.lineWidth = 1.5
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                ctx.beginPath()
                                ctx.moveTo(2, 12); ctx.lineTo(5, 6); ctx.lineTo(8, 9)
                                ctx.lineTo(11, 4); ctx.lineTo(14, 7)
                                ctx.stroke()
                                ctx.beginPath()
                                ctx.arc(2, 12, 1.5, 0, Math.PI * 2)
                                ctx.fillStyle = root.c_start
                                ctx.fill()
                                ctx.beginPath()
                                ctx.arc(14, 7, 1.5, 0, Math.PI * 2)
                                ctx.fillStyle = root.c_track
                                ctx.fill()
                            }
                        }

                        Text {
                            text: "Routes"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: root.c_text
                            Layout.fillWidth: true
                        }

                        Text {
                            text: trackManager.trackNames.length
                            font.pixelSize: 11
                            color: root.c_muted
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: root.c_border }

                // Track list
                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: trackManager.trackNames
                    currentIndex: -1

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    Text {
                        anchors.centerIn: parent
                        visible: listView.count === 0
                        text: "No tracks found.\nPlace .csv files in\ntracks/ folder."
                        color: root.c_muted
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        lineHeight: 1.5
                    }

                    delegate: Item {
                        id: item
                        width: listView.width
                        height: 46

                        readonly property bool active: listView.currentIndex === index

                        Rectangle {
                            anchors { fill: parent; leftMargin: 6; rightMargin: 6; topMargin: 2; bottomMargin: 2 }
                            radius: 5
                            color: item.active ? root.c_selected
                                   : (area.containsMouse ? root.c_hover : "transparent")
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        // Active indicator bar
                        Rectangle {
                            visible: item.active
                            width: 2; height: 22; radius: 1
                            color: root.c_accent
                            anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                        }

                        RowLayout {
                            anchors {
                                left: parent.left; right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: item.active ? 20 : 16
                                rightMargin: 12
                            }
                            spacing: 8

                            // Track icon per item
                            Canvas {
                                width: 14; height: 14
                                Layout.alignment: Qt.AlignVCenter
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, 14, 14)
                                    ctx.strokeStyle = item.active ? root.c_accent : root.c_muted
                                    ctx.lineWidth = 1.5
                                    ctx.lineCap = "round"
                                    ctx.lineJoin = "round"
                                    ctx.beginPath()
                                    ctx.moveTo(1, 11); ctx.lineTo(4, 6)
                                    ctx.lineTo(7, 8); ctx.lineTo(10, 3); ctx.lineTo(13, 6)
                                    ctx.stroke()
                                    ctx.beginPath()
                                    ctx.arc(1, 11, 1.2, 0, Math.PI * 2)
                                    ctx.fillStyle = root.c_start
                                    ctx.fill()
                                    ctx.beginPath()
                                    ctx.arc(13, 6, 1.2, 0, Math.PI * 2)
                                    ctx.fillStyle = root.c_track
                                    ctx.fill()
                                }

                                Connections {
                                    target: item
                                    function onActiveChanged() { parent.requestPaint() }
                                }
                            }

                            Text {
                                text: modelData
                                font.pixelSize: 12
                                color: item.active ? root.c_accent : root.c_text
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 12; rightMargin: 12 }
                            height: 1; color: root.c_border; opacity: 0.4
                        }

                        MouseArea {
                            id: area
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                listView.currentIndex = index
                                loadTrack(index)
                            }
                        }
                    }
                }
            }
        }

        Rectangle { Layout.preferredWidth: 1; Layout.fillHeight: true; color: root.c_border }

        // ── Map ──────────────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Map {
                id: map
                anchors.fill: parent
                plugin: mapPlugin
                center: QtPositioning.coordinate(52.0, 31.0)
                zoomLevel: 8
                copyrightsVisible: true

                MapPolyline {
                    id: polyline
                    line.width: 3
                    line.color: root.c_track
                    path: []
                }

                MapQuickItem {
                    id: markerA
                    visible: polyline.path.length > 0
                    anchorPoint: Qt.point(10, 10)
                    sourceItem: Rectangle {
                        width: 20; height: 20; radius: 10
                        color: root.c_start; border.color: "white"; border.width: 2
                        Text { anchors.centerIn: parent; text: "S"; font.pixelSize: 8; font.bold: true; color: "white" }
                    }
                }

                MapQuickItem {
                    id: markerB
                    visible: polyline.path.length > 1
                    anchorPoint: Qt.point(10, 10)
                    sourceItem: Rectangle {
                        width: 20; height: 20; radius: 10
                        color: root.c_track; border.color: "white"; border.width: 2
                        Text { anchors.centerIn: parent; text: "E"; font.pixelSize: 8; font.bold: true; color: "white" }
                    }
                }
            }

            Rectangle {
                anchors.centerIn: parent
                visible: polyline.path.length === 0
                width: 230; height: 44; radius: 8
                color: Qt.rgba(0.06, 0.09, 0.16, 0.88)
                border.color: root.c_border
                Text {
                    anchors.centerIn: parent
                    text: "Select a route from the list"
                    color: root.c_muted; font.pixelSize: 12
                }
            }

            // Status bar
            Rectangle {
                visible: statusName.text !== ""
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 32
                color: Qt.rgba(0.06, 0.09, 0.16, 0.9)

                RowLayout {
                    anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                    spacing: 12

                    Rectangle { width: 6; height: 6; radius: 3; color: root.c_accent }

                    Text {
                        id: statusName
                        text: ""; color: root.c_text; font.pixelSize: 12
                    }
                    Text {
                        id: statusPoints
                        text: ""; color: root.c_muted; font.pixelSize: 11
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            // Zoom controls
            Column {
                anchors { right: parent.right; top: parent.top; rightMargin: 10; topMargin: 10 }
                spacing: 1

                Repeater {
                    model: [{ lbl: "+", d: 1 }, { lbl: "−", d: -1 }]
                    delegate: Rectangle {
                        width: 32; height: 32; radius: 4
                        color: zm.containsMouse ? root.c_hover : Qt.rgba(0.06, 0.09, 0.16, 0.88)
                        border.color: root.c_border
                        Text { anchors.centerIn: parent; text: modelData.lbl; color: root.c_text; font.pixelSize: 17 }
                        MouseArea {
                            id: zm; anchors.fill: parent; hoverEnabled: true
                            onClicked: map.zoomLevel = Math.max(2, Math.min(19, map.zoomLevel + modelData.d))
                        }
                    }
                }
            }
        }
    }

    function loadTrack(index) {
        polyline.path = []

        if (!trackManager.isTrackValid(index)) {
            errorDetail.text = "\"" + trackManager.trackNames[index] + ".csv\" — no valid coordinates found."
            errorModal.visible = true
            statusName.text = ""
            statusPoints.text = ""
            return
        }

        const raw = trackManager.getTrackCoordinates(index)
        if (!raw || raw.length === 0) {
            errorDetail.text = "\"" + trackManager.trackNames[index] + ".csv\" — file is empty or unreadable."
            errorModal.visible = true
            return
        }

        const path = []
        for (let i = 0; i < raw.length; ++i)
            path.push(QtPositioning.coordinate(raw[i].latitude, raw[i].longitude))

        polyline.path      = path
        markerA.coordinate = path[0]
        markerB.coordinate = path[path.length - 1]
        map.center         = path[0]
        map.zoomLevel      = 15

        statusName.text   = trackManager.trackNames[index]
        statusPoints.text = raw.length + " points"
    }
}
