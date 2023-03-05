import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: page
    allowedOrientations: Orientation.All

    onStatusChanged: {

        if (page.status === PageStatus.Inactive) largeTypeModel.clear();

    }

    SilicaGridView {

        id: largeTypeGridView
        model: largeTypeModel
        cellWidth: page.isPortrait ? Screen.width / 5 : Screen.height > 1920 ? Screen.height / 11 : Screen.height / 9
        cellHeight: cellWidth * 1.1

        anchors.fill: parent

        delegate: GridItem {

            id: gridItem
            enabled: false

            Label {

                id: characterLargeType
                text: "<pre>" + character + "</pre>"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeHuge
                textFormat: Text.AutoText
                width: parent.width
                bottomPadding: 0

                Component.onCompleted: {

                    this.topPadding = (parent.height - this.contentHeight) / 2;

                }

            }

            Rectangle {

                id: shadeRectangle
                width: parent.width
                height: parent.height
                color: Theme.highlightColor
                opacity: 0.1
                visible: Math.abs(index % 2) == 0

            }

        }

    }

}
