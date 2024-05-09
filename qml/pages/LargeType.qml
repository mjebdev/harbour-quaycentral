import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: page
    allowedOrientations: Orientation.All
    readonly property int landscapeCount: Screen.height > 1920 ? 11 : 9
    readonly property int cellWidthCalc: page.isPortrait ? Screen.width / 5 : Screen.height / landscapeCount
    readonly property int cellHeightCalc: cellWidthCalc + Theme.paddingLarge + Theme.paddingSmall

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
                anchors.top: parent.top
                width: parent.width
                height: width
                text: "<pre>" + character + "</pre>"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeHuge
                maximumLineCount: 1

                Component.onCompleted: {

                    if (/\d/.test(text)) color = Theme.highlightColor; // Thanks to user jackocnr on Stack Overflow -- https://stackoverflow.com/questions/8935632/check-if-character-is-number

                }

            }

            Label {

                id: characterNumber
                text: index + 1
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.secondaryColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                height: Theme.paddingLarge + Theme.paddingSmall
                anchors.bottom: parent.bottom

                Rectangle {

                    anchors.fill: parent
                    z: -100
                    color: Theme.overlayBackgroundColor

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
