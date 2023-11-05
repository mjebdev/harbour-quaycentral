import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: page
    allowedOrientations: Orientation.All
    readonly property int landscapeCount: Screen.height > 1920 ? 11 : 9
    readonly property int cellWidthCalc: page.isPortrait ? Screen.width / 5 : Screen.height / landscapeCount
    readonly property int cellHeightCalc: cellWidthCalc * 1.1

    onStatusChanged: {

        if (page.status === PageStatus.Inactive) largeTypeModel.clear();

    }

    SilicaGridView {

        id: largeTypeGridView
        model: largeTypeModel
        cellWidth: cellWidthCalc
        cellHeight: cellHeightCalc
        width: parent.width

        header: Item {

            width: parent.width
            height: page.isPortrait ? Screen.height < (cellHeightCalc * Math.ceil(largeTypeModel.count / 5)) ? 0 : (Screen.height - (cellHeightCalc * Math.ceil(largeTypeModel.count / 5))) / 2 : Screen.width < (cellHeightCalc * Math.ceil(largeTypeModel.count / landscapeCount)) ? 0 : (Screen.width - (cellHeightCalc * Math.ceil(largeTypeModel.count / landscapeCount))) / 2

        }

        x: page.isPortrait ? largeTypeModel.count < 5 ? (Screen.width - (cellWidthCalc * largeTypeModel.count)) / 2 : 0 : largeTypeModel.count < landscapeCount ? (Screen.height - (cellWidthCalc * largeTypeModel.count)) / 2 : 0
        anchors.top: parent.top
        anchors.bottom: parent.bottom

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
                opacity: Math.abs(index % 2) == 0 ? 0.07 : 0.12

            }

        }

    }

}
