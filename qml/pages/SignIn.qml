import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool skippingVaultScreen
    property bool haveSessionKey

    onStatusChanged: {

        if (status === PageStatus.Active) {

            if (appPastLaunch) { // A swipe back, vault(s) will be locked.

                signOutProcess.start("op", ["signout"]);
                itemDetailsModel.clear();
                itemListModel.clear();
                favItemsModel.clear();
                vaultListModel.clear();
                currentSession = "000000000000000000000000000000000000000000000000000000000000000000000000";
                currentSession = "";
                skippingVaultScreen = false; // this needs to be switched back to false in order to allow signin, will later be set to Settings value.
                statusLabel.text = "";
                passwordField.visible = true;
                passwordField.opacity = 1.0;
                haveSessionKey = false;

            }

            else { // First view of signin screen following app launch.

                installationCheck.start("op", ["--version"]);
                versionCheckTimer.start();
                appPastLaunch = true;

            }

        }

    }

    SilicaListView {

        anchors.fill: parent

        Column {

            id: column
            anchors.fill: parent

            Row {

                id: titleRow
                width: titleLabel.width
                height: parent.height * 0.2
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
                    text: "v0.7"
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

                id: signinRow
                width: parent.width * 0.7
                height: passwordField.height
                x: parent.width * 0.15

                PasswordField {

                    id: passwordField
                    visible: false
                    labelVisible: false
                    textMargin: Theme.paddingMedium
                    horizontalAlignment: "AlignHCenter"
                    placeholderText: qsTr("Enter Master Password")
                    showEchoModeToggle: false
                    opacity: Theme.highlightBackgroundOpacity
                    passwordMaskDelay: 0

                    Behavior on opacity {

                        FadeAnimator {}

                    }

                    onTextChanged: {

                        if (text === "" || text === "0000000000000000000000000000000000000000000000000000000000000000") {

                            loginButton.opacity = 0.0;
                            loginButton.enabled = false;
                            EnterKey.enabled = false;

                        }

                        else {

                            statusLabel.text = "";
                            statusLabel.color = Theme.primaryColor; // back to default color
                            loginButton.enabled = true;
                            loginButton.opacity = 1.0;
                            EnterKey.enabled = true;

                        }

                    }

                    EnterKey.onClicked: {

                        errorReadout = "";
                        processOne.start("op", ["signin", "--account", "quaycentsfos", "--raw"]);
                        statusLabel.text = qsTr("Unlocking...");
                        processOne.write(passwordField.text + "\n");
                        passwordField.focus = false;
                        passwordField.opacity = 0.0;
                        passwordField.visible = false;
                        loginButton.opacity = 0.0;
                        loginButton.enabled = false;
                        passwordField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                        passwordField.text = "";
                        loggingInBusy.running = true;

                    }

                }

            }

            Row {

                width: loginButton.width
                height: loginButton.height + (parent.height * 0.04) // for spacing between text field and button
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

                            errorReadout = "";
                            processOne.start("op", ["signin", "--account", "quaycentsfos", "--raw"]);
                            statusLabel.text = qsTr("Unlocking...");
                            processOne.write(passwordField.text + "\n");
                            passwordField.focus = false;
                            passwordField.opacity = 0.0;
                            passwordField.visible = false;
                            loginButton.opacity = 0.0;
                            loginButton.enabled = false;
                            passwordField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                            passwordField.text = "";
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

            errorReadout = readAllStandardError();
            versionCheckTimer.stop();
            titleLabel.color = "grey";
            appVersionLabel.color = "grey";
            statusLabel.color = Theme.errorColor;
            statusLabel.text = qsTr("Unable to communicate with CLI.\n\nPlease confirm that 1Password CLI has been installed in /usr/bin or /usr/local/bin and relaunch QuayCentral.");
            statusRow.height = statusLabel.paintedHeight;

        }

    }

    Process {

        id: processOne

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();

            if (haveSessionKey) {

                if (settings.loadFavItems) {

                    favItemsModel.clear();
                    processOne.waitForFinished();
                    var favsOutput = readAllStandardOutput();
                    var favsOutputParsed = JSON.parse(favsOutput);

                    if (favsOutputParsed.length > 0) {

                        anyFavItems = true;
                        for (var i = 0; i < favsOutputParsed.length; i++) favItemsModel.append({itemId: favsOutputParsed[i].id, itemTitle: favsOutputParsed[i].title, itemType: favsOutputParsed[i].category, itemVaultId: favsOutputParsed[i].vault.id, itemVaultName: favsOutputParsed[i].vault.name});

                    }

                    else anyFavItems = false;

                    if (settings.skipVaultScreen) {

                        skippingVaultScreen = true;

                        if (settings.loadAllItems) {

                            statusLabel.text = qsTr("Listing all items...");
                            processThree.start("op", ["item", "list", "--format", "json", "--session", currentSession]);

                        }

                        else {

                            statusLabel.text = qsTr("Listing categorized items...");
                            processThree.start("op", ["item", "list", "--categories", settings.whichItemsToLoad, "--format", "json", "--session", currentSession]);

                        }

                    }

                    else {

                        loggingInBusy.running = false;
                        statusLabel.text = "";
                        pageStack.push(Qt.resolvedUrl("Vaults.qml"));

                    }

                }

                else {

                    itemListModel.clear();
                    itemSearchModel.clear();
                    processOne.waitForFinished();
                    var prelimOutput = readAllStandardOutput();
                    var itemList = JSON.parse(prelimOutput);

                    for (var i = 0; i < itemList.length; i++) {

                        itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name});
                        itemSearchModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name});

                    }

                    loggingInBusy.running = false;
                    statusLabel.text = "";
                    pageStack.push([Qt.resolvedUrl("Vaults.qml"), Qt.resolvedUrl("Items.qml")]);

                }

            }

            else {

                currentSession = readAllStandardOutput();
                currentSession = currentSession.trim();
                haveSessionKey = true;
                statusLabel.text = qsTr("Unlocked, listing vaults...");
                processTwo.start("op", ["vault", "list", "--format", "json", "--session", currentSession]);

            }

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("Unauthorized") !== -1) {

                loggingInBusy.running = false;
                statusLabel.color = Theme.errorColor;
                statusLabel.text = qsTr("Incorrect password");
                passwordField.visible = true;
                passwordField.opacity = 1.0;

            }

            else if (errorReadout.indexOf("o accounts configured") !== -1 || errorReadout.indexOf("o accounts found matching filter") !== -1) {

                loggingInBusy.running = false;
                statusLabel.horizontalAlignment = "AlignLeft";
                statusLabel.text = qsTr("QuayCentral shorthand has not been added to the 1Password command-line tool.\n\nPlease add the shorthand when adding your account to the CLI (\"--shorthand quaycentsfos\") and restart app.");
                statusRow.height = statusLabel.height;

            }

            else if (errorReadout.indexOf("dial tcp") !== -1) {

                if (errorReadout.indexOf("i/o timeout") !== -1) {

                    loggingInBusy.running = false;
                    statusLabel.color = Theme.errorColor;
                    statusLabel.text = qsTr("Connection to server timed out. Please check device's network connection.");
                    passwordField.visible = true;
                    passwordField.opacity = 1.0;

                }

                else {

                    loggingInBusy.running = false;
                    statusLabel.color = Theme.errorColor;
                    statusLabel.text = qsTr("Network connection error");
                    passwordField.visible = true;
                    passwordField.opacity = 1.0;

                }

            }

            else {

                loggingInBusy.running = false;
                statusLabel.color = Theme.errorColor;
                statusLabel.text = qsTr("Error: ") + errorReadout.slice(28);
                titleLabel.color = "grey"
                appVersionLabel.color = "grey"
                statusRow.height = statusLabel.height;

            }

            sessionExpiryTimer.stop();

        }

    }

    Process {

        id: processTwo

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();
            var prelimOutput = readAllStandardOutput();
            var vaultList = JSON.parse(prelimOutput);
            vaultListModel.clear();

            if (vaultList.length === 1) justOneVault = true;

            else {

                justOneVault = false;
                vaultListModel.append({name: "All Vaults", uuid: "ALL_VAULTS", categories: categoryListModel});

            }

            for (var i = 0; i < vaultList.length; i++) {

                vaultListModel.append({name: vaultList[i].name, uuid: vaultList[i].id,
                categories: categoryListModel});

            }

            statusLabel.text = qsTr("Vault listing complete.");

            if (settings.loadFavItems) {

                statusLabel.text = qsTr("Listing favorite items...");
                processOne.start("op", ["item", "list", "--favorite", "--format", "json", "--session", currentSession]);

            }

            else {

                anyFavItems = false;

                if (settings.skipVaultScreen) {

                    skippingVaultScreen = true;

                    if (settings.loadAllItems) {

                        statusLabel.text = qsTr("Listing all items...");
                        processOne.start("op", ["item", "list", "--format", "json", "--session", currentSession]);
                    }

                    else {

                        statusLabel.text = qsTr("Listing categorized items...");
                        processOne.start("op", ["item", "list", "--categories", settings.whichItemsToLoad, "--format", "json", "--session", currentSession]);

                    }

                }

                else {

                    loggingInBusy.running = false;
                    statusLabel.text = "";
                    pageStack.push(Qt.resolvedUrl("Vaults.qml"));

                }

            }

        }

        onReadyReadStandardError: {

            sessionExpiryTimer.stop();
            statusLabel.color = Theme.errorColor;
            statusLabel.text = qsTr("Error occurred while accessing vault data.");

        }

    }

    Process {

        id: processThree // for when user is both loading Favs and bypassing Vaults page.

        onReadyReadStandardOutput: {

            itemListModel.clear();
            itemSearchModel.clear();
            processThree.waitForFinished();
            var prelimOutput = readAllStandardOutput();
            var itemList = JSON.parse(prelimOutput);

            for (var i = 0; i < itemList.length; i++) {

                itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name});
                itemSearchModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name});

            }

            loggingInBusy.running = false;
            statusLabel.text = "";
            pageStack.push([Qt.resolvedUrl("Vaults.qml"), Qt.resolvedUrl("Items.qml")]);

        }

        onReadyReadStandardError: {

            sessionExpiryTimer.stop();
            statusLabel.color = Theme.errorColor;
            statusLabel.text = qsTr("Error occurred while listing items.");

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
        interval: 2500

        onTriggered: {

            titleLabel.color = "grey"
            appVersionLabel.color = "grey"
            statusLabel.color = Theme.errorColor;
            statusLabel.text = qsTr("No response from CLI.\n\nPlease confirm that 1Password CLI has been installed in /usr/bin or /usr/local/bin and relaunch QuayCentral.")
            statusRow.height = statusLabel.height;

        }

    }

}
