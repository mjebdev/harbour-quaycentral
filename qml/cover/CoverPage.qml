import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: cover
    allowResize: true

    Image {

        id: coverBackgroundIcon
        source: "BW_harbour-quaycentral.png"
        width: parent.height - (Theme.paddingMedium * 2)
        height: width
        fillMode: Image.PreserveAspectFit
        opacity: 0.15

        anchors {

            verticalCenter: parent.verticalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium

        }

    }

    ListView {

        id: totpListView
        model: totpModel

        anchors {

            top: parent.top
            left: parent.left
            right: parent.right
            bottom: coverActionArea.top

        }

        Label {

            id: lowerLabel
            anchors.centerIn: parent
            text: ""
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            opacity: 0.0
            font.pixelSize: cover.size === Cover.Large ? Theme.fontSizeLarge : Theme.fontSizeMedium
            //font.bold: true
            //z: -1

            Behavior on opacity {

                FadeAnimator {

                    duration: 250

                }

            }

        }

        delegate: Column {

            width: parent.width
            height: cover.height - coverActionArea.height
            visible: active && settings.otpOnCover

            onVisibleChanged: { // to allow for clearer otp in highlight color

                if (visible) coverBackgroundIcon.opacity = 0.05;
                else coverBackgroundIcon.opacity = 0.15;

            }

            Row {

                id: topPaddingRow
                width: parent.width
                height: cover.size === Cover.Large ? (Theme.paddingLarge * 2) : Theme.paddingMedium

            }

            Row {

                width: cover.size === Cover.Large ? parent.width - (Theme.paddingLarge * 2) : parent.width - (Theme.paddingMedium * 2)
                height: (parent.height - totpTimerProgressBarRow.height - topPaddingRow.height) / 2
                x: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                Label {

                    id: totpLabel1
                    width: parent.width
                    //height: parent.height
                    text: totpPart1
                    textFormat: Text.AutoText
                    font.pixelSize: Theme.fontSizeHuge
                    //font.bold: primaryColor
                    font.letterSpacing: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    color: primaryColor ? Theme.highlightColor : Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    opacity: primaryColor ? 1.0 : 0.2
                    //verticalAlignment: "AlignVCenter" //  -- does not work with fixed width text / <pre>
                    leftPadding: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    rightPadding: 0
                    //bottomPadding: 0

                }

            }

            Row {

                width: cover.size === Cover.Large ? parent.width - (Theme.paddingLarge * 2) : parent.width - (Theme.paddingMedium * 2)
                height: (parent.height - totpTimerProgressBarRow.height - topPaddingRow.height) / 2
                x: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                Label {

                    id: totpLabel2
                    width: parent.width
                    //height: parent.height
                    text: totpPart2
                    textFormat: Text.AutoText
                    font.pixelSize: Theme.fontSizeHuge
                    //font.bold: primaryColor
                    font.letterSpacing: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    color: primaryColor ? Theme.highlightColor : Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    opacity: primaryColor ? 1.0 : 0.2
                    //verticalAlignment: "AlignVCenter" // does not work for <pre> text
                    leftPadding: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium // the font.letterSpacing value offsets horizontal centering somewhat
                    rightPadding: 0
                    topPadding: 0 // cover.size === Cover.Large ? 0 : Theme.paddingMedium

                }

            }

            Row {

                id: totpTimerProgressBarRow
                width: cover.size === Cover.Large ? parent.width - (Theme.paddingLarge * 2) : parent.width - (Theme.paddingMedium * 2)
                height: cover.size === Cover.Large ? totpTimerProgressBar.height + (Theme.paddingLarge * 2) : totpTimerProgressBar.height + Theme.paddingMedium // putting a bit more space between bar and the lock button.
                x: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                ProgressBar {

                    id: totpTimerProgressBar
                    anchors.top: totpLabel2.bottom
                    width: parent.width
                    minimumValue: 0
                    maximumValue: 30
                    //visible: active
                    value: secondsLeft
                    leftMargin: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    rightMargin: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                }

            }

        }

    }

    CoverActionList {

        id: coverActionList

        CoverAction {

            id: coverAction
            iconSource: "image://theme/icon-s-secure"

            onTriggered: {

                lowerLabel.text = lockItUp(false);
                lowerLabel.opacity = 1.0;
                lockedTextTimer.start();

            }

        }

    }

    Timer {

        id: lockedTextTimer
        interval: 1000

        onTriggered: {

            lowerLabel.opacity = 0.0

        }

    }

}
