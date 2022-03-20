import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: coverBackground
    allowResize: true

    Image {

        id: coverBackgroundIcon
        source: "harbour-quaycentral.png"
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

    Label {

        id: lowerLabel
        anchors.centerIn: parent
        text: ""
        color: Theme.highlightColor
        wrapMode: Text.Wrap
        opacity: 0.0
        font.pixelSize: Theme.fontSizeLarge
        font.bold: true

        Behavior on opacity {

            FadeAnimator {

                duration: 250

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
