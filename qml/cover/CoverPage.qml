import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: coverBackground

    Column {

        height: coverBackground.height
        anchors.fill: parent
        spacing: Theme.horizontalPageMargin

        Row {

            width: parent.width
            height: parent.height * 0.4
            spacing: 0

            Label {

                id: label
                text: "QuayCentral"
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeLarge
                width: parent.width
                height: parent.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignBottom

            }

        }

        Row {

            width: parent.width
            height: parent.height * 0.3
            spacing: 0
            y: parent.height * 0.5

            Label {

                id: lowerLabel
                text: ""
                wrapMode: Text.Wrap
                opacity: 0.0
                font.pixelSize: Theme.fontSizeLarge
                width: parent.width
                height: parent.height
                horizontalAlignment: Text.AlignHCenter

                Behavior on opacity {

                    FadeAnimator {

                        duration: 330

                    }

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
