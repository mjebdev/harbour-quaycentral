import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property int secondsCountdown
    property string totpOutput

    SilicaListView {

        id: itemDetailsView
        anchors.fill: parent
        model: itemDetailsModel

        PullDownMenu {

            /* - a likely feature further on in development
            MenuItem {

                text: "Edit"

                onClicked: {

                    usernameField.text = "Feature not yet enabled.";

                }

            }
            */

            MenuItem {

                text: qsTr("Lock");
                onClicked: lockItUp(false);

            }

            MenuItem {

                text: qsTr("Copy Password")
                visible: itemDetailsModel.get(0).password === "" ? false : true

                onClicked: {

                    Clipboard.text = itemDetailsModel.get(0).password;
                    detailsPagePasswordCopied.previewSummary = qsTr("Copied")
                    detailsPagePasswordCopied.publish();

                }

            }

            MenuItem {

                id: copyTotpMenu
                text: qsTr("Copy One-Time Password")
                visible: false

                onClicked: {

                    Clipboard.text = totpOutput;
                    detailsPagePasswordCopied.previewSummary = qsTr("One-Time Password Copied")
                    detailsPagePasswordCopied.publish();

                }

            }

        }

        delegate: Column {

            id: column
            anchors.fill: parent
            spacing: 0
            width: page.width

            Component.onCompleted: {

                getTotp.start("op", ["get", "totp", uuid, "--session", currentSession]);

            }

            Timer {

                id: totpTimer
                interval: 500
                repeat: true
                triggeredOnStart: false

                onTriggered: {

                    var totpCurrentTime = new Date;
                    secondsCountdown = totpCurrentTime.getSeconds();
                    if (secondsCountdown > 29) secondsCountdown = secondsCountdown - 30;
                    secondsCountdown = (secondsCountdown - 30) * -1;
                    totpTimerField.text = secondsCountdown.toString();

                }

            }

            Process {

                id: getTotp

                onReadyReadStandardOutput: {

                    sessionExpiryTimer.restart();
                    totpOutput = readAllStandardOutput();
                    totpTextField.text = totpOutput.slice(0, 3) + " " + totpOutput.slice(3);
                    totpTextField.color = Theme.primaryColor;
                    totpTimerField.color = Theme.primaryColor;
                    totpCopyButton.enabled = true;
                    gatheringTotpBusy.running = false;

                    if (totpRow.visible == false) { // if first time checking for totp in item

                        totpRow.visible = true;
                        copyTotpMenu.visible = true;
                        totpTimer.start();

                    }

                }

                onReadyReadStandardError: {

                    sessionExpiryTimer.restart();

                    if (totpRow.visible) { // have there already been successful TOTP grabs?

                        detailsPagePasswordCopied.previewSummary = qsTr("Error loading one-time password. Please check network connection and try accessing page again.");
                        detailsPagePasswordCopied.expireTimeout = 2500;
                        detailsPagePasswordCopied.publish();
                        detailsPagePasswordCopied.expireTimeout = 800; // put back to default for copying notifications
                        gatheringTotpBusy.running = false;

                    }

                    else errorReadout = readAllStandardError(); // leave TOTP row invisible.

                }

            }

            PageHeader {

                id: titleHeader
                title: itemTitle

            }

            Row {

                width: parent.width
                id: usernameRow
                height: usernameField.height + (Theme.paddingMedium * 2)
                spacing: 0

                Column {

                    height: parent.height
                    width: parent.width - usernameCopyButton.width - usernameField.textLeftMargin - Theme.paddingMedium + (usernameCopyButton.width / 8)
                    spacing: 0

                    Row {

                        width: parent.width
                        spacing: Theme.paddingMedium

                        TextField {

                            id: usernameField
                            label: qsTr("username")
                            readOnly: true
                            text: username
                            y: passwordCopyButton.width / 8

                        }

                    }

                }

                Column {

                    height: parent.height
                    width: usernameCopyButton.width
                    spacing: Theme.paddingMedium

                    Row {

                        spacing: 0
                        width: parent.width

                        Image {

                            id: usernameCopyButton
                            source: "image://theme/icon-m-clipboard"
                            y: 0

                            MouseArea {

                                anchors.fill: parent

                                onClicked: {

                                    Clipboard.text = username;
                                    detailsPagePasswordCopied.previewSummary = qsTr("Username Copied")
                                    detailsPagePasswordCopied.publish();

                                }

                            }

                        }

                    }

                }

            }

            Row {

                width: parent.width
                id: passwordRow
                height: itemDetailsPasswordField.height + (Theme.paddingMedium * 2)
                spacing: 0

                Column {

                    height: parent.height
                    width: parent.width - passwordCopyButton.width - itemDetailsPasswordField.textLeftMargin - Theme.paddingMedium + (passwordCopyButton.width / 8)
                    spacing: 0

                    Row {

                        width: parent.width
                        spacing: Theme.paddingMedium

                        PasswordField {

                            id: itemDetailsPasswordField
                            readOnly: true
                            text: password
                            label: qsTr("password")
                            y: passwordCopyButton.width / 8

                        }

                    }

                }

                Column {

                    height: parent.height
                    width: passwordCopyButton.width
                    spacing: Theme.paddingMedium

                    Row {

                        spacing: 0
                        width: parent.width

                        Image {

                            id: passwordCopyButton
                            source: "image://theme/icon-m-clipboard"
                            y: 0

                            MouseArea {

                                anchors.fill: parent

                                onClicked: {

                                    Clipboard.text = password;
                                    detailsPagePasswordCopied.previewSummary = qsTr("Copied")
                                    detailsPagePasswordCopied.publish();

                                }

                            }

                        }

                    }

                }

            }

            // To account for difference in size between show-password button and the copy button (48x48 and 64x64 respectively),
            // nudging down the fields to align correctly with copy button (passwordCopyButton.width / 8).

            Row {

                width: parent.width
                id: totpRow
                visible: false
                height: itemDetailsPasswordField.height + (Theme.paddingMedium * 2) // since text may not yet be filled in
                spacing: 0

                Column {

                    height: parent.height
                    width: parent.width - passwordCopyButton.width - itemDetailsPasswordField.textLeftMargin - Theme.paddingMedium + (passwordCopyButton.width / 8)
                    spacing: 0

                    Row {

                        width: parent.width
                        spacing: Theme.paddingMedium

                        TextField {

                            id: totpTextField
                            font.letterSpacing: 6
                            readOnly: true
                            label: qsTr("one-time password")
                            y: passwordCopyButton.width / 8
                            width: parent.width - Theme.paddingMedium

                            rightItem: Label {

                                id: totpTimerField
                                horizontalAlignment: Qt.AlignHCenter
                                width: totpCopyButton.width * 0.75

                                Rectangle {

                                    height: gatheringTotpBusy.height + (gatheringTotpBusy.y * 2)
                                    color: "transparent"
                                    opacity: 1.0
                                    radius: 12

                                    anchors {

                                        top: parent.top
                                        left: parent.left
                                        right: parent.right

                                    }

                                    border {

                                        id: totpTimerBorder
                                        width: 2
                                        color: Theme.highlightColor

                                    }

                                }

                                onTextChanged: {

                                    var digit = parseInt(text);

                                    if (digit < 11) {

                                        totpTimerBorder.color = Theme.errorColor;

                                    }

                                    else {

                                        totpTimerBorder.color = Theme.highlightColor;

                                        if (digit === 30) {

                                            gatheringTotpBusy.running = true;
                                            totpTextField.color = "grey";
                                            totpTimerField.color = "grey";
                                            totpCopyButton.enabled = false;
                                            getTotp.start("op", ["get", "totp", uuid, "--session", currentSession]);

                                        }

                                    }

                                }

                                BusyIndicator {

                                    id: gatheringTotpBusy
                                    size: BusyIndicatorSize.Small
                                    anchors.centerIn: parent
                                    running: false

                                }

                            }

                        }

                    }

                }

                Column {

                    height: parent.height
                    width: totpCopyButton.width
                    spacing: Theme.paddingMedium

                    Row {

                        spacing: 0
                        width: parent.width

                        Image {

                            id: totpCopyButton
                            source: "image://theme/icon-m-clipboard"
                            y: 0

                            MouseArea {

                                anchors.fill: parent

                                onClicked: {

                                    Clipboard.text = totpOutput;
                                    detailsPagePasswordCopied.previewSummary = qsTr("One-Time Password Copied")
                                    detailsPagePasswordCopied.publish();

                                }

                            }

                        }

                    }

                }

            }

            Row {

                width: parent.width
                id: websiteRow
                visible: websiteField.text === "" ? false : true

                TextArea {

                    id: websiteField
                    label: qsTr("website")
                    readOnly: true
                    text: website
                    color: Theme.highlightColor
                    y: passwordCopyButton.width / 8

                    onClicked: {

                        if (text.slice(0, 4) !== "http") {

                            // To avoid for "Cannot open file. File was not found." error.
                            var needsHttp = "https://" + text;
                            Qt.openUrlExternally(needsHttp);

                        }

                        else Qt.openUrlExternally(text);

                    }

                }

            }

        }

    }

    Notification {

        id: detailsPagePasswordCopied
        appName: "QuayCentral"
        urgency: Notification.Low
        isTransient: true
        expireTimeout: 800

    }

}
