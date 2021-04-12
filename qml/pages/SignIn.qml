import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool skippingVaultScreen: false

    onStatusChanged: {

        if (status === PageStatus.Active) {

            if (appPastLaunch) {

                signOutProcess.start("op", ["signout"]);
                itemDetailsModel.setProperty(0, "username", "000000000000000000000000000000000000000000000000000000000000000000000000");
                itemDetailsModel.setProperty(0, "password", "000000000000000000000000000000000000000000000000000000000000000000000000");
                itemDetailsModel.clear();
                itemListModel.clear();
                itemTitle.length = 0;
                itemTitleToUpperCase.length = 0;
                currentSession = "000000000000000000000000000000000000000000000000000000000000000000000000";
                currentSession = "";
                skippingVaultScreen = false; // this needs to be switched back to false in order to allow signin, will later be set to Settings value.
                statusLabel.text = "";
                passwordField.visible = true;
                passwordField.opacity = 1.0;

            }

            else { // this is the first view of signin screen following app launch

                installationCheck.start("op", ["--version"]); // confirming CLI is installed upon each launch, otherwise
                appPastLaunch = true;                         // password field will not appear.
                versionCheckTimer.start();

            }

        }

    }

    SilicaListView {

        anchors.fill: parent

        Column {

            id: column
            spacing: 0
            anchors.fill: parent

            Row {

                id: titleRow
                width: titleLabel.width
                height: parent.height * 0.2
                spacing: 0
                x: (page.width - titleLabel.width) / 2

                Label {

                    id: titleLabel
                    text: "QuayCentral"
                    font.pixelSize: Theme.fontSizeHuge
                    color: Theme.highlightColor
                    bottomPadding: 0
                    height: parent.height
                    verticalAlignment: "AlignBottom"

                }

            }

            Row {

                width: parent.width
                id: versionRow
                height: (parent.height * 0.18) - (passwordField.height / 2)

                Label {

                    id: appVersionLabel
                    text: "v0.1"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: parent.width
                    horizontalAlignment: "AlignHCenter"
                    verticalAlignment: "AlignTop"
                    topPadding: 0
                    height: parent.height

                }

            }

            Row {

                width: parent.width
                id: statusRow
                height: (parent.height * 0.12)

                TextArea {

                    id: statusLabel
                    text: ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                    readOnly: true

                }

            }

            Row {

                id: errorSeparator
                visible: false
                spacing: 0

                Separator {

                    color: Theme.errorColor
                    width: statusLabel.width
                    horizontalAlignment: Qt.AlignHCenter
                    x: (page.width - statusLabel.width) / 2

                }

            }

            Row {

                id: signinRow
                width: parent.width * 0.7
                height: passwordField.height
                x: parent.width * 0.15
                spacing: 0

                PasswordField {

                    id: passwordField
                    visible: false
                    labelVisible: false
                    textMargin: Theme.paddingMedium
                    horizontalAlignment: "AlignHCenter"
                    placeholderText: qsTr("Enter Master Password")
                    showEchoModeToggle: false
                    opacity: Theme.highlightBackgroundOpacity
                    passwordMaskDelay: 0  // don't want character to be visible at all

                    Behavior on opacity {

                        FadeAnimator {}

                    }

                    onTextChanged: {

                        if (text === "") {

                            loginButton.opacity = 0.0;
                            loginButton.enabled = false;
                            EnterKey.enabled = false;

                        }

                        else {

                            statusLabel.text = "";
                            loginButton.enabled = true;
                            loginButton.opacity = 1.0;
                            EnterKey.enabled = true;

                        }

                    }

                    EnterKey.onClicked: {

                        processOne.start("op", ["signin", "quaycentsfos", "--raw"]);
                        processOne.write(passwordField.text + "\n");
                        passwordField.focus = false;
                        passwordField.opacity = 0.0;
                        passwordField.visible = false;
                        loginButton.opacity = 0.0;
                        loginButton.enabled = false;
                        passwordField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                        passwordField.text = "";
                        statusLabel.text = qsTr("Unlocking...");
                        loggingInBusy.running = true;

                    }

                }

            }

            Row {

                width: loginButton.width
                height: loginButton.height + (parent.height * 0.04) // for spacing between text field and button
                spacing: 0
                x: (page.width - loginButton.width) * 0.5

                Image {

                    id: loginButton
                    source: "image://theme/icon-m-accept"
                    opacity: 0.0
                    y: (column.height * 0.04)

                    Behavior on opacity {

                        FadeAnimator {}

                    }

                    MouseArea {

                        anchors.fill: parent

                        onClicked: {

                            processOne.start("op", ["signin", "quaycentsfos", "--raw"]);
                            processOne.write(passwordField.text + "\n");
                            passwordField.focus = false;
                            passwordField.opacity = 0.0;
                            passwordField.visible = false;
                            loginButton.opacity = 0.0;
                            loginButton.enabled = false;
                            passwordField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                            passwordField.text = "";
                            statusLabel.text = qsTr("Unlocking...");
                            loggingInBusy.running = true;

                        }

                    }

                }

            }

        }

    }

    Process {

        id: installationCheck

        onReadyReadStandardOutput: {

            versionCheckTimer.stop();
            cliVersion = readAllStandardOutput();
            cliVersion = cliVersion.trim();
            passwordField.visible = true;
            passwordField.opacity = 1.0;

        }

        onReadyReadStandardError: {

            versionCheckTimer.stop();
            titleLabel.color = "grey"
            appVersionLabel.color = "grey"
            statusLabel.text = qsTr("Unable to communicate with CLI.\n\nPlease confirm that 1Password CLI has been installed in /usr/local/bin and relaunch QuayCentral.")
            statusRow.height = statusLabel.paintedHeight;
            errorSeparator.visible = true;

        }

    }

    Process {

        id: processOne

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();

            if (skippingVaultScreen) {

                itemListModel.clear();
                processOne.waitForFinished();
                var prelimOutput = readAllStandardOutput();
                itemList = JSON.parse(prelimOutput);

                for (var i = 0; i < itemList.length; i++) {

                    itemTitle[i] = itemList[i].overview.title;
                    itemTitleToUpperCase[i] = itemList[i].overview.title.toUpperCase();
                    itemUUID[i] = itemList[i].uuid;
                    itemListModel.append({uuid: itemUUID[i], title: itemTitle[i]});

                }

                loggingInBusy.running = false;
                statusLabel.text = "";
                pageStack.push(Qt.resolvedUrl("Items.qml"));

            }

            else {

                currentSession = readAllStandardOutput();
                currentSession = currentSession.trim();
                statusLabel.text = qsTr("Unlocked, listing vaults...");
                processTwo.start("op", ["list", "vaults", "--session", currentSession]);

            }

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("Unauthorized") !== -1) {

                loggingInBusy.running = false;
                statusLabel.text = qsTr("Incorrect Password");
                passwordField.visible = true;
                passwordField.opacity = 1.0;

            }

            else if (errorReadout.indexOf("Account not found") !== -1) {

                loggingInBusy.running = false;
                statusLabel.text = qsTr("1Password command-line tool has not been configured.\n\nPlease setup tool to accept QuayCentral requests and relaunch app.");
                titleLabel.color = "grey"
                appVersionLabel.color = "grey"
                statusRow.height = statusLabel.height;
                errorSeparator.visible = true;

            }

            else {

                loggingInBusy.running = false;
                statusLabel.text = qsTr("Unknown error:\n") + errorReadout;
                titleLabel.color = "grey"
                appVersionLabel.color = "grey"
                statusRow.height = statusLabel.height;
                errorSeparator.visible = true;

            }

            sessionExpiryTimer.stop();

        }

    }

    Process {

        id: processTwo

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();
            var prelimOutput = readAllStandardOutput();
            vaultList = JSON.parse(prelimOutput);
            vaultListModel.clear();

            for (var i = 0; i < vaultList.length; i++) {

                vaultName[i] = vaultList[i].name;
                vaultUUID[i] = vaultList[i].uuid;
                vaultListModel.append({name: vaultName[i], uuid: vaultUUID[i]});

            }

            // need to assign default vault as first vault if no default exists.

            statusLabel.text = qsTr("Vault listing complete.");

            if (settings.skipVaultScreen) {

                skippingVaultScreen = true;
                statusLabel.text = qsTr("Listing vault items...");
                processOne.start("op", ["list", "items", "--categories", "Login", "--vault", settings.defaultVaultUUID, "--session", currentSession]);

            }

            else {

                // skippingVaultScreen = false;
                loggingInBusy.running = false;
                statusLabel.text = "";
                pageStack.push(Qt.resolvedUrl("Vaults.qml"));

            }

        }

        onReadyReadStandardError: {

            sessionExpiryTimer.stop();
            statusLabel.text = qsTr("Error occurred when gathering Vault data.");

        }

    }

    BusyIndicator {

        id: loggingInBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: false

    }

    Timer {

        id: versionCheckTimer
        interval: 5000

        onTriggered: {

            titleLabel.color = "grey"
            appVersionLabel.color = "grey"
            statusLabel.text = qsTr("No response from CLI.\n\nPlease confirm that 1Password CLI has been installed in /usr/local/bin and relaunch QuayCentral.")
            statusRow.height = statusLabel.height;
            errorSeparator.visible = true;

        }

    }

}
