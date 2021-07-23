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

            MenuItem {

                visible: settings.includeLockMenuItem
                text: qsTr("Lock");
                onClicked: lockItUp(false);

            }

            MenuItem {

                id: copyTotpMenu
                text: qsTr("Copy One-Time Password")
                visible: false

                onClicked: {

                    Clipboard.text = totpOutput;
                    detailsPageNotification.previewSummary = qsTr("Copied one-time password to clipboard")
                    detailsPageNotification.publish();

                }

            }

            MenuItem {

                text: qsTr("Copy Password")
                visible: itemDetailsModel.get(0).password === "" ? false : true

                onClicked: {

                    Clipboard.text = itemDetailsModel.get(0).password;
                    detailsPageNotification.previewSummary = qsTr("Copied password to clipboard")
                    detailsPageNotification.publish();

                }

            }

        }

        delegate: Column {

            id: column
            anchors.fill: parent
            spacing: 0
            width: page.width

            Component.onCompleted: {

                getTotp.start("op", ["get", "totp", uuid, "--vault", itemsVault, "--session", currentSession]);

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

                    totpOutput = readAllStandardOutput();
                    totpOutput = totpOutput.trim();

                    if (totpRow.visible == false) { // if first time checking for totp in item

                        totpRow.visible = true;
                        copyTotpMenu.visible = true;
                        totpTimer.start();

                    }

                    totpTextField.text = totpOutput.slice(0, 3) + " " + totpOutput.slice(3);
                    totpTextField.color = Theme.primaryColor;
                    totpTimerField.color = Theme.primaryColor;
                    totpCopyButton.enabled = true;
                    gatheringTotpBusy.running = false;
                    sessionExpiryTimer.restart();

                }

                onReadyReadStandardError: {

                    errorReadout = readAllStandardError();

                    if (errorReadout.indexOf("does not contain a one-time password") === -1) { // else no action needed, totpRow remains invisible, timer just restarted by previous page.

                        sessionExpiryTimer.stop();
                        gatheringTotpBusy.running = false;

                        if (errorReadout.indexOf("session expired") !== -1) detailsPageNotification.previewSummary = "Session Expired";
                        else if (errorReadout.indexOf("not currently signed in") !== -1) detailsPageNotification.previewSummary = "Not Currently Signed In";

                        else {

                            // there have already been successful TOTP grabs, possible network error.
                            detailsPageNotification.previewSummary = "Unknown Error - Please check network and try signing in again.";
                            Clipboard.text = errorReadout;

                        }

                        detailsPageNotification.publish();
                        pageStack.clear();
                        pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

                    }

                }

            }

            PageHeader {

                id: titleHeader
                title: itemTitle

            }

            Row {

                width: parent.width
                id: paddingRow
                height: Theme.paddingLarge

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
                                    detailsPageNotification.previewSummary = qsTr("Copied username to clipboard")
                                    detailsPageNotification.publish();

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
                                    detailsPageNotification.previewSummary = qsTr("Copied password to clipboard")
                                    detailsPageNotification.publish();

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
                            text: "/././. /././."
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
                                    radius: 20

                                    anchors {

                                        top: parent.top
                                        left: parent.left
                                        right: parent.right

                                    }

                                    border {

                                        id: totpTimerBorder
                                        width: 3
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
                                            getTotp.start("op", ["get", "totp", uuid, "--vault", itemsVault, "--session", currentSession]);

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
                                    detailsPageNotification.previewSummary = qsTr("Copied one-time password to clipboard")
                                    detailsPageNotification.publish();

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

                        if (text.slice(0, 4) !== "http") { // To avoid "Cannot open file. File was not found." error.

                            var needsHttp = "https://" + text;
                            Qt.openUrlExternally(needsHttp);

                        }

                        else Qt.openUrlExternally(text);

                    }

                }

            }

        }

        VerticalScrollDecorator { }

    }

    Notification {

        id: detailsPageNotification
        appName: "QuayCentral"
        urgency: Notification.Low
        isTransient: true
        expireTimeout: 800

    }

}
