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
                            font.bold: true
                            color: Theme.highlightColor
                            topPadding: Theme.paddingLarge
                            bottomPadding: Theme.paddingSmall

                        }

                    }

                    Row {

                        width: parent.width * 0.1
                        x: (parent.width - this.width) / 2
                        bottomPadding: Theme.paddingLarge

                        Image {

                            width: parent.width
                            source: "harbour-quaycentral.svg";
                            height: width

                        }

                    }

                    Separator {

                        id: titleSeparator
                        width: parent.width * 0.66
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
                            text: qsTr("A GUI app for the 1Password command-line tool on Sailfish OS.\n\nby Michael J. Barrett\nmjeb.dev\n\nVersion 0.9.4\nLicensed under GNU GPLv3\n\nMuch-appreciated app icon contributed by JSEHV on GitHub.\n\nQuayCentral is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.\n\nVersion %1 of the 1Password command-line tool is installed on your device.").arg(cliVersion);
                            topPadding: Theme.paddingLarge * 2
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }

                    Separator {

                        id: aboutTextSeparator
                        width: parent.width * 0.66
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Separator.Center
                        color: Theme.primaryColor

                    }

                    Row {

                        width: parent.width
                        height: Theme.paddingLarge

                    }

                    Row {

                        id: linkToKoFiRow
                        width: parent.width * 0.4
                        x: parent.width * 0.3
                        height: parent.width * 0.25

                        Image {

                            id: linkToKoFi
                            source: "kofi_logo.webp"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.ko-fi.com/mjebdev");

                            }

                        }

                    }

                    Row {

                        width: parent.width * 0.4
                        x: parent.width * 0.3
                        height: parent.width * 0.25

                        Image {

                            id: linkToGitHub
                            source: Theme.colorScheme == Theme.DarkOnLight ? "GitHub_Logo_cropped_to_content.png" : "GitHub_Logo_White_cropped_to_content.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/mjebdev/harbour-seachest");

                            }

                        }

                    }

                    Row {

                        id: linkToPayPalRow
                        width: parent.width * 0.4
                        x: parent.width * 0.3
                        height: parent.width * 0.25

                        Image {

                            id: linkToPayPal
                            source: Theme.colorScheme == Theme.DarkOnLight ? "PayPal_logo_black_cropped_to_content.png" : "PayPal_logo_white_cropped_to_content.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: (parent.height - height) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.paypal.me/mjebdev");

                            }

                        }

                    }

                    Row {

                        id: bmacGapRow
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
