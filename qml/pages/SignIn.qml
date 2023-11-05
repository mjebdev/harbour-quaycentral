import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool skippingVaultScreen
    property bool haveSessionKey
    property bool checkingShorthand

    onStatusChanged: {

        if (status === PageStatus.Active) {

            if (appPastLaunch) { // A swipe back, vault(s) will be locked.

                signOutProcess.start("op", ["signout"]);
                itemDetailsModel.clear();
                itemListModel.clear();
                itemSearchModel.clear();
                favItemsModel.clear();
                vaultListModel.clear();
                currentSession = "000000000000000000000000000000000000000000000000000000000000000000000000";
                currentSession = "";
                getToSetupPage.visible = false;
                skippingVaultScreen = false; // this needs to be switched back to false in order to allow signin, will later be set to Settings value.
                statusLabel.text = "";
                passwordField.visible = true;
                passwordField.opacity = 1.0;
                haveSessionKey = false;

            }

            else { // First view of signin screen following app launch.

                getToSetupPage.visible = false; // incase coming back from setup page without CLI yet installed.
                statusLabel.text = "";
                statusLabel.color = Theme.primaryColor;
                statusLabel.horizontalAlignment = "AlignHCenter";
                appPastLaunch = true;
                // Need to check for userland architecture (as opposed to kernel architecture which will show as aarch64 even on Xperia X and XA2)
                // Many thanks to olf and nephros on Sailfish OS Forum for this guidance:
                // https://forum.sailfishos.org/t/detection-of-sfos-armv7hl-vs-sfos-aarch64/9239
                architectureCheck.start("/usr/bin/getconf", ["LONG_BIT"]);

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
                    text: "v0.8"
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

                Label {

                    id: statusLabel
                    text: ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.primaryColor
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                    leftPadding: Theme.horizontalPageMargin
                    rightPadding: Theme.horizontalPageMargin
                    //readOnly: true
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    onLinkActivated: Qt.openUrlExternally(link)

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

            Row {

                id: getToSetupPage
                visible: false
                width: parent.width

                ButtonLayout {

                    id: setupButtonLayout

                    Button {

                        text: "Setup"

                        onClicked: {

                            statusLabel.text = "";
                            statusLabel.horizontalAlignment = "AlignHCenter";
                            statusRow.height = column.height * 0.12;
                            setupButtonLayout.visible = false;
                            appPastLaunch = false;
                            pageStack.push(Qt.resolvedUrl("Setup.qml"));

                        }

                    }

                }

            }

        }

    }

    Process {

        id: installationCheck

        onReadyReadStandardOutput: {

            // need to check for quaycentsfos shorthand

            versionCheckTimer.stop();
            cliVersion = readAllStandardOutput();
            cliVersion = cliVersion.trim();

            checkingShorthand = true;
            architectureCheck.start("op", ["account", "list", "--format", "json"]);

            titleLabel.color = Theme.highlightColor; // incase coming back from setup page etc.
            appVersionLabel.color = Theme.secondaryColor;

        }

    }

    Process {

        id: architectureCheck

        onReadyReadStandardOutput: {

            if (checkingShorthand) {

                const listOfAccounts = readAllStandardOutput();

                console.log("Got past readyReadyStandardOutput for process.");

                if (listOfAccounts == "[]") {

                    console.log("listOfAccounts blank or null. Status label should be showing.");
                    loggingInBusy.running = false;
                    statusLabel.horizontalAlignment = "AlignLeft";
                    statusLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("QuayCentral shorthand has not been added to the 1Password command-line tool.\n\nClick 'Setup' below to add, or manually add via Terminal [op account add --shorthand quaycentsfos]. Instructions @ <a href='https://developer.1password.com/docs/cli/sign-in-manually/#set-a-custom-account-shorthand'>1Password Developer</a>.");
                    statusRow.height = statusLabel.height;
                    getToSetupPage.visible = true;

                }

                else {

                    console.log("listOfAccounts not blank, checking for shorthand now.");
                    var parsedListOfAccounts = JSON.parse(listOfAccounts);
                    var matchFound = false;
                    for (var i = 0; i < parsedListOfAccounts.length; i++) if (parsedListOfAccounts[i].shorthand == "quaycentsfos") matchFound = true;

                    if (matchFound) {

                        titleLabel.color = Theme.highlightColor; // incase coming back from setup page etc.
                        appVersionLabel.color = Theme.secondaryColor;
                        passwordField.visible = true;
                        passwordField.opacity = 1.0;

                    }

                    else { // shorthand not yet added.

                        loggingInBusy.running = false;
                        statusLabel.horizontalAlignment = "AlignLeft";
                        statusLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("QuayCentral shorthand has not been added to the 1Password command-line tool.\n\nClick 'Setup' below to add, or manually add via Terminal [op account add --shorthand quaycentsfos]. Instructions @ <a href='https://developer.1password.com/docs/cli/sign-in-manually/#set-a-custom-account-shorthand'>1Password Developer</a>.");
                        statusRow.height = statusLabel.height;
                        getToSetupPage.visible = true;

                    }

                }

            }

            else {

                var architecture = readAllStandardOutput();
                if (architecture == 64) runningOnAarch64 = true;
                else runningOnAarch64 = false;
                installationCheck.start("op", ["--version"]);
                versionCheckTimer.start();

            }

        }

        onReadyReadStandardError: {

            if (checkingShorthand) { // unknown error checking account list

                console.log("Error when gathering account list - " + readAllStandardError());
                loggingInBusy.running = false;
                statusLabel.color = Theme.errorColor;
                statusLabel.horizontalAlignment = "AlignHCenter";
                statusLabel.text = qsTr("Unknown error when gathering account list. Please quit and restart app.");

            }

            else { // error checking CPU architecture / 32 vs 64bit. very unlikely?

                console.log("Error determining type of CPU - " + readAllStandardError());
                notifySessionExpired.previewSummary = qsTr("Error determing CPU architecture type.");
                notifySessionExpired.publish();
                installationCheck.start("op", ["--version"]); // runningOnAarch64 will remain false. need to check for install in any case.
                versionCheckTimer.start();

            }

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

                        if (settings.defaultVaultUuid == "" || settings.defaultVaultUuid == "ALL_VAULTS") {

                            if (settings.loadAllItems) {

                                statusLabel.text = qsTr("Listing all items...");
                                itemCategoryListingType = "";
                                processThree.start("op", ["item", "list", "--format", "json", "--session", currentSession]);

                            }

                            else {

                                statusLabel.text = qsTr("Listing categorized items...");
                                itemCategoryListingType = settings.whichItemsToLoad;
                                processThree.start("op", ["item", "list", "--categories", settings.whichItemsToLoad, "--format", "json", "--session", currentSession]);

                            }

                        }

                        else {

                            if (settings.loadAllItems) {

                                statusLabel.text = qsTr("Listing all items...");
                                itemCategoryListingType = "";
                                processThree.start("op", ["item", "list", "--vault", settings.defaultVaultUuid, "--format", "json", "--session", currentSession]);

                            }

                            else {

                                statusLabel.text = qsTr("Listing categorized items...");
                                itemCategoryListingType = settings.whichItemsToLoad;
                                processThree.start("op", ["item", "list", "--vault", settings.defaultVaultUuid, "--categories", settings.whichItemsToLoad, "--format", "json", "--session", currentSession]);

                            }

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

                    if (itemCategoryListingType == "") {

                        for (var i = 0; i < itemList.length; i++) {

                            switch (itemList[i].category) {

                            case "API_CREDENTIAL": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                                break;

                            case "BANK_ACCOUNT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🏦"});
                                break;

                            case "CREDIT_CARD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "💳"});
                                break;

                            case "CUSTOM": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""}); // Bitcoin emoji not showing up on SFOS.
                                break;

                            case "DATABASE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🗃️"});
                                break;

                            case "DOCUMENT":
                                if (itemList[i].overview.ainfo !== null) itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: itemList[i].created_at, docUpdatedAt: itemList[i].updated_at, docAdditionalInfo: itemList[i].overview.ainfo});
                                else itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: itemList[i].created_at, docUpdatedAt: itemList[i].updated_at});
                                break;

                            case "DRIVER_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🚘"});
                                break;

                            case "EMAIL_ACCOUNT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-mail", iconEmoji: ""});
                                break;
                            // ID among others to be included in default (contact card icon)
                            //case "IDENTITY": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                                //break;

                            case "LOGIN": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                                break;

                            case "MEDICAL_RECORD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "⚕️"});
                                break;

                            //case "MEMBERSHIP": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                                //break;

                            case "OUTDOOR_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🏕️"});
                                break;

                            case "PASSPORT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🛂"});
                                break;

                            case "PASSWORD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                                break;

                            case "REWARD_PROGRAM": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🎁"});
                                break;

                            case "SECURE_NOTE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-note", iconEmoji: ""});
                                break;

                            case "SERVER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🖧"});
                                break;

                            //case "SOCIAL_SECURITY_NUMBER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                                //break;

                            case "SOFTWARE_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "💾"});
                                break;

                            case "SSH_KEY": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                                break;

                            case "WIRELESS_ROUTER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-wlan", iconEmoji: ""});
                                break;

                            default: // A catch-all for Identity, Membership and Social Security Number, as these will all have the same ID-card icon.
                                itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-vcard", iconEmoji: ""});

                            }

                            itemSearchModel.append(itemListModel.get(i));

                        }

                    }

                    else {

                        var emojiString = "";
                        var iconString = "";

                        switch (itemCategoryListingType) {

                        case "Login":

                            emojiString = "";
                            iconString = "image://theme/icon-m-keys";
                            break;

                        case "Secure Note":

                            emojiString = "";
                            iconString = "image://theme/icon-m-note";
                            break;

                        case "Credit Card":

                            emojiString = "💳";
                            iconString = "";
                            break;
/*
                        case "Identity":

                            emojiString = "";
                            iconString = "";
                            break;
*/
                        case "API Credential":

                            emojiString = "";
                            iconString = "image://theme/icon-m-keys";
                            break;

                        case "Bank Account":

                            emojiString = "🏦";
                            iconString = "";
                            break;

                        case "Database":

                            emojiString = "🗃️";
                            iconString = "";
                            break;

                        case "Document":

                            emojiString = "";
                            iconString = "image://theme/icon-m-file-document-dark";
                            break;

                        case "Driver License":

                            emojiString = "🚘";
                            iconString = "";
                            break;

                        case "Email Account":

                            emojiString = "";
                            iconString = "image://theme/icon-m-mail";
                            break;
/*
                        case "Membership":

                            emojiString = "";
                            iconString = "";
                            break;
*/
                        case "Outdoor License":

                            emojiString = "🏕️";
                            iconString = "";
                            break;

                        case "Passport":

                            emojiString = "🛂";
                            iconString = "";
                            break;

                        case "Password":

                            emojiString = "";
                            iconString = "image://theme/icon-m-keys";
                            break;

                        case "Reward Program":

                            emojiString = "🎁";
                            iconString = "";
                            break;

                        case "Server":

                            emojiString = "🖧";
                            iconString = "";
                            break;
/*
                        case "Social Security Number":

                            emojiString = "";
                            iconString = "";
                            break;
*/
                        case "Software License":

                            emojiString = "💾";
                            iconString = "";
                            break;

                        case "SSH Key":

                            iconString = "image://theme/icon-m-keys";
                            break;

                        case "Wireless Router":

                            iconString = "image://theme/icon-m-wlan";
                            break;

                        default:

                            iconString = "image://theme/icon-m-file-vcard";

                        }

                        for (var i = 0; i < itemList.length; i++) {

                            itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: iconString, iconEmoji: emojiString});
                            itemSearchModel.append(itemListModel.get(i));

                        }



                    }





                    loggingInBusy.running = false;
                    statusLabel.text = "";
                    itemListingFin = true;
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
                statusLabel.color = Theme.highlightColor;
                statusLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("QuayCentral shorthand has not been added to the 1Password command-line tool.\n\nClick 'Setup' below to add, or manually add via Terminal [op account add --shorthand quaycentsfos]. Instructions @ <a href='https://developer.1password.com/docs/cli/sign-in-manually/#set-a-custom-account-shorthand'>1Password Developer</a>.");
                statusRow.height = statusLabel.height;
                getToSetupPage.visible = true;

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
                itemCategoryListingType = "";
                processOne.start("op", ["item", "list", "--favorite", "--format", "json", "--session", currentSession]);

            }

            else {

                anyFavItems = false;

                if (settings.skipVaultScreen) {

                    skippingVaultScreen = true;

                    if (settings.defaultVaultUuid == "" || settings.defaultVaultUuid == "ALL_VAULTS") {

                        if (settings.loadAllItems) {

                            statusLabel.text = qsTr("Listing all items...");
                            itemCategoryListingType = "";
                            processOne.start("op", ["item", "list", "--format", "json", "--session", currentSession]);
                        }

                        else {

                            statusLabel.text = qsTr("Listing categorized items...");
                            itemCategoryListingType = settings.whichItemsToLoad;
                            processOne.start("op", ["item", "list", "--categories", settings.whichItemsToLoad, "--format", "json", "--session", currentSession]);

                        }

                    }

                    else {

                        if (settings.loadAllItems) {

                            statusLabel.text = qsTr("Listing all items...");
                            itemCategoryListingType = "";
                            processOne.start("op", ["item", "list", "--vault", settings.defaultVaultUuid, "--format", "json", "--session", currentSession]);
                        }

                        else {

                            statusLabel.text = qsTr("Listing categorized items...");
                            itemCategoryListingType = settings.whichItemsToLoad;
                            processOne.start("op", ["item", "list", "--vault", settings.defaultVaultUuid, "--categories", settings.whichItemsToLoad, "--format", "json", "--session", currentSession]);

                        }

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

                switch (itemList[i].category) {

                case "API_CREDENTIAL": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                    break;

                case "BANK_ACCOUNT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🏦"});
                    break;

                case "CREDIT_CARD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "💳"});
                    break;

                case "CUSTOM": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""}); // Bitcoin emoji not showing up on SFOS.
                    break;

                case "DATABASE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🗃️"});
                    break;

                case "DOCUMENT":
                    if (itemList[i].overview.ainfo !== null) itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: itemList[i].created_at, docUpdatedAt: itemList[i].updated_at, docAdditionalInfo: itemList[i].overview.ainfo});
                    else itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: itemList[i].created_at, docUpdatedAt: itemList[i].updated_at});
                    break;

                case "DRIVER_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🚘"});
                    break;

                case "EMAIL_ACCOUNT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-mail", iconEmoji: ""});
                    break;

                case "LOGIN": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                    break;

                case "MEDICAL_RECORD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "⚕️"});
                    break;

                case "OUTDOOR_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🏕️"});
                    break;

                case "PASSPORT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🛂"});
                    break;

                case "PASSWORD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                    break;

                case "REWARD_PROGRAM": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🎁"});
                    break;

                case "SECURE_NOTE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-note", iconEmoji: ""});
                    break;

                case "SERVER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🖧"});
                    break;

                case "SOFTWARE_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "💾"});
                    break;

                case "SSH_KEY": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                    break;

                case "WIRELESS_ROUTER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-wlan", iconEmoji: ""});
                    break;
// A catch-all for Identity, Membership and Social Security Number, as these will all have the same ID-card icon.
                default: itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-vcard", iconEmoji: ""});

                }

                itemSearchModel.append(itemListModel.get(i));

            }

            loggingInBusy.running = false;
            statusLabel.text = "";
            itemListingFin = true;
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
        interval: 2000

        onTriggered: {

            titleLabel.color = "grey";
            appVersionLabel.color = "grey";
            statusLabel.horizontalAlignment = "AlignLeft";
            statusLabel.color = Theme.highlightColor;

            if (runningOnAarch64) {

                statusLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("CLI not found on this device.\n\nPlease confirm that 1Password CLI has been installed and relaunch app. Instructions to install are at <a href='https://developer.1password.com/docs/cli/get-started'>1Password Developer</a>. Alternatively, you may download and install the CLI by clicking Setup below.");
                getToSetupPage.visible = true;

            }

            else statusLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("CLI not found on this device.\n\nPlease confirm that 1Password CLI has been installed and relaunch app. Instructions to install are at <a href='https://developer.1password.com/docs/cli/get-started'>1Password Developer</a>.");

            statusRow.height = statusLabel.height;

        }

    }

}
