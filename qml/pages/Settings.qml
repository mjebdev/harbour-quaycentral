import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool signOutError: false

    /*  to be enabled in some form when there is a Sailfish-Secrets implementation on the app, which will in turn allow
        the secure storage of the default vault UUID.
    Component.onCompleted: {

        // determine current index of default vault combo by confirming place in list of current default.
        for (var i = 0; i < vaultUUID.length; i++) {

            if (settings.defaultVaultUUID === vaultUUID[i]) {

                defaultVaultCombo.currentIndex = i;

            }

        }

    }
    */

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {

            MenuItem {

                text: qsTr("Lock");
                onClicked: lockItUp(false);

            }

        }

        Column {

            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {

                title: qsTr("Settings")

            }

            SectionHeader {

                text: qsTr("Login Item Search")

            }

            ComboBox {

                label: qsTr("Enter key")
                id: enterKeyCombo
                width: parent.width
                currentIndex: settings.enterKeyLoadsDetails ? 0 : 1

                menu: ContextMenu {

                    MenuItem {

                        text: qsTr("loads top item details")

                        onClicked: {

                            settings.enterKeyLoadsDetails = true;
                            settings.sync();

                        }

                    }

                    MenuItem {

                        text: qsTr("copies top item password")

                        onClicked: {

                            settings.enterKeyLoadsDetails = false;
                            settings.sync();

                        }

                    }

                }

            }

            ComboBox {

                label: qsTr("Tapping item")
                id: tappingCombo
                width: parent.width
                currentIndex: settings.tapToCopy ? 1 : 0

                menu: ContextMenu {

                    MenuItem {

                        text: qsTr("loads details")

                        onClicked: {

                            settings.tapToCopy = false;
                            settings.sync();

                        }

                    }

                    MenuItem {

                        text: qsTr("copies password")

                        onClicked: {

                            settings.tapToCopy = true;
                            settings.sync();

                        }

                    }

                }

            }

            Label {

                id: pressAndHoldInfoLabel
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width
                text: tappingCombo.currentIndex === 1 ? qsTr("Press and hold for item details.") : qsTr("Press and hold to copy password.")
                wrapMode: Text.Wrap
                leftPadding: sessionExpiryNotifySwitch.leftMargin
                //topPadding: 0

            }

            /*  to be enabled in some form when there is a Sailfish-Secrets implementation on the app, which will in turn allow
                the secure storage of the default vault UUID.

            ComboBox {

                label: "Default Vault"
                id: defaultVaultCombo
                width: parent.width

                menu: ContextMenu {

                    Repeater {

                        model: vaultName

                        MenuItem {

                            text: modelData

                            onClicked: {

                                settings.defaultVaultUUID = vaultUUID[index];
                                settings.sync();

                            }

                        }

                    }

                }

            }
            */

            SectionHeader {

                text: qsTr("Item Details");

            }

            TextSwitch {

                text: qsTr("Mask credit card account numbers")
                id: hideCcnumSwitch
                checked: settings.ccnumHidden

                onCheckedChanged: {

                    settings.ccnumHidden = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("Login Session (Alpha)")

            }

            ComboBox {

                label: qsTr("Lock when CLI is inactive for")
                id: sessionLengthCombo
                currentIndex: settings.sessionTimeIndex

                menu: ContextMenu {

                    MenuItem {

                        text: qsTr("30 seconds")

                        onClicked: {

                            settings.sessionTimeLength = 30000;
                            settings.sessionTimeIndex = 0;
                            settings.sync();
                            sessionExpiryTimer.restart();

                        }

                    }

                    MenuItem {

                        text: qsTr("2 minutes")

                        onClicked: {

                            settings.sessionTimeLength = 120000;
                            settings.sessionTimeIndex = 1;
                            settings.sync();
                            sessionExpiryTimer.restart();

                        }

                    }

                    MenuItem {

                        text: qsTr("5 minutes")

                        onClicked: {

                            settings.sessionTimeLength = 300000;
                            settings.sessionTimeIndex = 2;
                            settings.sync();
                            sessionExpiryTimer.restart();

                        }

                    }

                    MenuItem {

                        text: qsTr("15 minutes")

                        onClicked: {

                            settings.sessionTimeLength = 900000;
                            settings.sessionTimeIndex = 3;
                            settings.sync();
                            sessionExpiryTimer.restart();

                        }

                    }

                    MenuItem {

                        text: qsTr("30 minutes")

                        onClicked: {

                            settings.sessionTimeLength = 1790000; // ten-second buffer to account for any processing delay when interacting with CLI
                            settings.sessionTimeIndex = 4;
                            settings.sync();
                            sessionExpiryTimer.restart();

                        }

                    }

                }

            }

            // To be enabled in some form when there is a Sailfish-Secrets implementation in the app, with which the default vault UUID can be stored securely.
            /*
            TextSwitch {

                text: "Skip vault selection screen and go directly to item listing for default vault."
                id: skipVaultScreenSwitch
                enabled: settings.moreThanOneVault
                checked: settings.skipVaultScreen

                onCheckedChanged: {

                    settings.skipVaultScreen = checked;
                    settings.sync();

                }

            }
            */

            TextSwitch {

                text: qsTr("Notify when session expires")
                id: sessionExpiryNotifySwitch
                checked: settings.sessionExpiryNotify

                onCheckedChanged: {

                    settings.sessionExpiryNotify = checked;
                    settings.sync();

                }

            }

            /*
            SectionHeader {

                text: qsTr("Command-Line Tool")

            }
            */

            /* todo: add response handling to confirm version is up to date or have update download and then show path in a notification.
            Row {

                width: parent.width
                spacing: 0

                Button {

                    text: "Update CLI"

                    onClicked: {

                        signOutProcess.start("op", ["update"]);

                    }

                }

            }
            */

            SectionHeader {

                text: qsTr("About")

            }

            Row {

                width: parent.width
                spacing: 0

                Column {

                    width: parent.width
                    spacing: 0

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
                            bottomPadding: Theme.paddingMedium

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

                        width: parent.width * 0.64
                        x: parent.width * 0.18
                        height: aboutTextLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            width: parent.width
                            id: aboutTextLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.styleName: Theme.primaryColor
                            wrapMode: Text.Wrap
                            text: qsTr("A GUI app for the 1Password command-line tool on Sailfish OS.\n\nBy Michael J. Barrett\n\nVersion 0.2 (alpha)\nLicensed under GNU GPLv3\n\nQuayCentral is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.\n\nVersion %1 of the 1Password command-line tool is installed on your device.").arg(cliVersion);
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Separator {

                        width: titleSeparator.width
                        x: (page.width - this.width) * 0.5
                        horizontalAlignment: Separator.Center
                        color: Theme.primaryColor

                    }

                    Row {

                        width: buyMeCoffeeLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: buyMeCoffeeLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            id: buyMeCoffeeLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.styleName: Theme.primaryColor
                            //font.italic: true
                            wrapMode: Text.Wrap
                            text: qsTr("Support")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        width: parent.width * 0.6
                        x: parent.width * 0.2
                        spacing: 0
                        height: linkToBMAC.height

                        Image {

                            id: linkToBMAC
                            source: Theme.colorScheme == Theme.DarkOnLight ? "BuyMeACoffee_Stroke_reduced_size.png" : "BuyMeACoffee_blue_reduced_size.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.buymeacoffee.com/michaeljb");

                            }

                        }

                    }

                    Row {

                        width: viewSourceCodeLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: viewSourceCodeLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            id: viewSourceCodeLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.styleName: Theme.primaryColor
                            //font.italic: true
                            wrapMode: Text.Wrap
                            text: qsTr("Source")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        width: linkToGitHub.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        spacing: 0
                        height: linkToBMAC.height

                        Image {

                            id: linkToGitHub
                            source: Theme.colorScheme == Theme.DarkOnLight ? "GitHub_Logo.png" : "GitHub_Logo_White.png"
                            fillMode: Image.PreserveAspectFit
                            height: parent.height

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://github.com/michaeljohnbarrett/harbour-quaycentral");

                            }

                        }

                    }

                    Row {

                        width: sendFeedbackLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: sendFeedbackLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            //width: parent.width
                            id: sendFeedbackLabel
                            font.pixelSize: Theme.fontSizeExtraSmall
                            font.styleName: Theme.primaryColor
                            //font.italic: true
                            wrapMode: Text.Wrap
                            text: qsTr("Feedback")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        spacing: 0
                        height: linkToBMAC.height
                        width: emailIconSeparate.width + feedbackEmail.width
                        x: (parent.width - this.width) * 0.5

                        Image {

                            id: emailIconSeparate
                            source: "image://theme/icon-m-mail"
                            fillMode: Image.PreserveAspectFit
                            height: parent.height
                            verticalAlignment: Image.AlignVCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("mailto://mjbarrett@eml.cc?subject=QuayCentral Feedback");

                            }

                        }

                        Label {

                            id: feedbackEmail
                            height: parent.height
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.highlightColor
                            text: "mjbarrett@eml.cc"
                            topPadding: 0
                            bottomPadding: this.paintedHeight * 0.17 // making this adjustment to keep vertically centered look with lowercase email.
                            leftPadding: Theme.paddingSmall
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("mailto:mjbarrett@eml.cc?subject=QuayCentral Feedback");

                            }

                        }

                    }

                    Row {

                        id: bmacGapRow
                        height: Theme.paddingMedium + Theme.paddingLarge + Theme.paddingSmall
                        width: parent.width

                    }

                }

            }

        }

    }

}
