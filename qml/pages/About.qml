import QtQuick 2.6
import Sailfish.Silica 1.0
import Process 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    Component.onCompleted: {

        versionCheck.start("op", ["--version"]);

    }

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        Column {

            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {

                title: qsTr("About")

            }

            Row {

                width: parent.width

                Column {

                    width: parent.width

                    Row {

                        width: aboutIcon.width + aboutTitle.width
                        x: (parent.width - this.width) / 2

                        Image {

                            id: aboutIcon
                            source: "harbour-quaycentral.svg";
                            height: Theme.itemSizeSmall
                            width: height

                        }

                        Label {

                            id: aboutTitle
                            text: "QuayCentral"
                            width: text.width
                            height: Theme.itemSizeSmall
                            verticalAlignment: Qt.AlignVCenter
                            font.pixelSize: Theme.fontSizeExtraLarge
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            leftPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }

                    Row {

                        width: parent.width - (Theme.horizontalPageMargin * 2)
                        x: Theme.horizontalPageMargin
                        height: aboutTextLabel.height

                        Label {

                            id: aboutTextLabel
                            width: parent.width
                            font.pixelSize: Theme.fontSizeExtraSmall
                            wrapMode: Text.Wrap
                            text: qsTr("A GUI app for the 1Password command-line tool on Sailfish OS.\n\nby Michael J. Barrett\n\nVersion 0.11\nLicensed under GNU GPLv3\n\nThanks to JSEHV on GitHub for the app icon.\n\nQuayCentral is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.\n\nVersion %1 of the 1Password command-line tool is installed on your device.").arg(cliVersion);
                            topPadding: Theme.paddingLarge
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    SectionHeader {

                        text: qsTr("Tip or View Source Code")

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge * 2

                    }

                    Row {

                        width: parent.width
                        height: Theme.itemSizeLarge

                        Image {

                            source: Theme.colorScheme == Theme.DarkOnLight ? "BMClogowithwordmark-black.png" : "BMClogowithwordmark-white.png"
                            fillMode: Image.PreserveAspectFit
                            height: Theme.itemSizeLarge
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.buymeacoffee.com/mjebdev");

                            }

                        }

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge * 2

                    }

                    Row {

                        width: parent.width
                        height: Theme.itemSizeMedium

                        Image {

                            source: Theme.colorScheme == Theme.DarkOnLight ? "GitHub_Lockup_Black.png" : "GitHub_Lockup_White.png"
                            fillMode: Image.PreserveAspectFit
                            height: Theme.itemSizeSmall
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/mjebdev/harbour-quaycentral");

                            }

                        }

                    }

                    Row {

                        height: Theme.paddingLarge
                        width: parent.width

                    }

                }

            }

        }

    }

    Process {

        id: versionCheck

        onReadyReadStandardOutput: {

            cliVersion = readAllStandardOutput();
            cliVersion = cliVersion.trim();

        }

    }

}
