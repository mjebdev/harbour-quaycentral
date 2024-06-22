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
/*
                    Row {

                        width: parent.width * 0.2
                        x: (parent.width - this.width) / 2

                        Image {

                            width: parent.width
                            source: "harbour-quaycentral.svg";
                            height: width

                        }

                    }
*/
                    Row {

                        width: appTitleLabel.width
                        x: (parent.width - appTitleLabel.width) * 0.5
                        spacing: 0

                        Label {

                            text: "QuayCentral"
                            width: text.width
                            height: text.height
                            horizontalAlignment: Qt.AlignHCenter
                            id: appTitleLabel
                            font.pixelSize: Theme.fontSizeLarge
                            //font.bold: true
                            color: Theme.highlightColor
                            topPadding: Theme.paddingLarge
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Separator {

                        id: titleSeparator
                        width: appTitleLabel.width
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Separator.Center
                        color: Theme.primaryColor

                    }

                    Row {

                        width: parent.width * 0.66
                        x: parent.width * 0.17
                        height: aboutTextLabel.height

                        Label {

                            id: aboutTextLabel
                            width: parent.width
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("A GUI app for the 1Password command-line tool on Sailfish OS.\n\nby Michael J. Barrett\nmjeb.dev\n\nVersion 0.9.1\nLicensed under GNU GPLv3\n\nApp icon by JSEHV on GitHub--Thank you for this contribution.\n\nQuayCentral is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.\n\nVersion %1 of the 1Password command-line tool is installed on your device.").arg(cliVersion);
                            topPadding: Theme.paddingLarge * 2
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }

                    Row {

                        width: linkToKoFi.width
                        x: (parent.width - linkToKoFi.width) / 2
                        height: Theme.itemSizeExtraSmall + (Theme.paddingMedium * 2)

                        Image {

                            id: linkToKoFi
                            source: Theme.colorScheme == Theme.DarkOnLight ? "Ko-fi_Logo_RGB_Dark.png" : "Ko-fi_Logo_RGB_DarkBg.png"
                            fillMode: Image.PreserveAspectFit
                            height: Theme.itemSizeExtraSmall
                            y: Theme.paddingMedium

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.ko-fi.com/michaeljb");

                            }

                        }

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }

                    Row {

                        width: linkToPayPal.width
                        x: (parent.width - linkToPayPal.width) / 2
                        height: Theme.itemSizeExtraSmall + (Theme.paddingMedium * 2)

                        Image {

                            id: linkToPayPal
                            source: Theme.colorScheme == Theme.DarkOnLight ? "PayPal_logo_black.png" : "PayPal_logo_white.png"
                            fillMode: Image.PreserveAspectFit
                            height: Theme.itemSizeExtraSmall
                            y: Theme.paddingMedium

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://paypal.me/michaeljohnbarrett");

                            }

                        }

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }

                    Row {

                        width: linkToGitHub.width
                        x: (parent.width - linkToGitHub.width) / 2
                        height: Theme.itemSizeExtraSmall + (Theme.paddingMedium * 2)

                        Image {

                            id: linkToGitHub
                            source: Theme.colorScheme == Theme.DarkOnLight ? "GitHub_Logo.png" : "GitHub_Logo_White.png"
                            fillMode: Image.PreserveAspectFit
                            height: Theme.itemSizeExtraSmall
                            y: Theme.paddingMedium
                            x: (parent.width - this.width) / 2

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/michaeljohnbarrett/harbour-quaycentral");

                            }

                        }

                    }

                    Row {

                        id: gapRow
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
