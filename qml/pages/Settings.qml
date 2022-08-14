import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import Process 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool updateAvailable
    property string releaseNotesURL
    property string updateFilePath

    Component.onCompleted: {

        versionCheck.start("op", ["--version"]);

    }

    onUpdateAvailableChanged: {

        if (updateAvailable) {

            updateCLI.write("y\n");
            updatingIndicator.running = true;
            updateDownloadTimer.start();
            processStatus.previewSummary = qsTr("Downloading update...");
            processStatus.publish();

        }

    }

    ListModel {

        id: allItemsOrOneCategoryModel

        ListElement {categoryName: ""; categoryDisplayName: "All Categories"}
        ListElement {categoryName: "Login"; categoryDisplayName: "Logins"}
        ListElement {categoryName: "Secure Note"; categoryDisplayName: "Secure Notes"}
        ListElement {categoryName: "Credit Card"; categoryDisplayName: "Credit Cards"}
        ListElement {categoryName: "Identity"; categoryDisplayName: "Identities"}
        ListElement {categoryName: "Bank Account"; categoryDisplayName: "Bank Accounts"}
        ListElement {categoryName: "Database"; categoryDisplayName: "Databases"}
        ListElement {categoryName: "Driver License"; categoryDisplayName: "Driver Licenses"}
        ListElement {categoryName: "Email Account"; categoryDisplayName: "Email Accounts"}
        ListElement {categoryName: "Medical Record"; categoryDisplayName: "Medical Records"}
        ListElement {categoryName: "Membership"; categoryDisplayName: "Memberships"}
        ListElement {categoryName: "Outdoor License"; categoryDisplayName: "Outdoor Licenses"}
        ListElement {categoryName: "Passport"; categoryDisplayName: "Passports"}
        ListElement {categoryName: "Password"; categoryDisplayName: "Passwords"}
        ListElement {categoryName: "Reward Program"; categoryDisplayName: "Reward Programs"}
        ListElement {categoryName: "Server"; categoryDisplayName: "Servers"}
        ListElement {categoryName: "Social Security Number"; categoryDisplayName: "Social Security Numbers"}
        ListElement {categoryName: "Software License"; categoryDisplayName: "Software Licenses"}
        ListElement {categoryName: "Wireless Router"; categoryDisplayName: "Wireless Routers"}

    }

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {

            visible: settings.includeLockMenuItem

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
                leftMargin: Theme.horizontalPageMargin

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
                description: currentIndex === 1 ? qsTr("Long press will load item details") : qsTr("Long press will copy password")
                id: tappingCombo
                width: parent.width
                currentIndex: settings.tapToCopy ? 1 : 0
                leftMargin: Theme.horizontalPageMargin

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

            SectionHeader {

                text: qsTr("Login Session")

            }

            TextSwitch {

                text: qsTr("Enable lockout timer")
                id: enableTimerSwitch
                checked: settings.enableTimer
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.enableTimer = checked;
                    if (checked) sessionExpiryTimer.restart();
                    settings.sync();

                }

            }

            ComboBox {

                label: qsTr("Lock when CLI is inactive for")
                id: sessionLengthCombo
                currentIndex: settings.sessionTimeIndex
                enabled: enableTimerSwitch.checked
                leftMargin: Theme.horizontalPageMargin

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

                }

            }

            TextSwitch {

                text: qsTr("Notify when session expires")
                id: sessionExpiryNotifySwitch
                checked: settings.sessionExpiryNotify
                enabled: enableTimerSwitch.checked
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.sessionExpiryNotify = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("Navigation")

            }

            TextSwitch {

                id: showLockMenuItemSwitch
                text: qsTr("Include 'Lock' menu on each screen")
                description: qsTr("Alternatively, tap padlock on cover or swipe back to sign-in screen.")
                checked: settings.includeLockMenuItem
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.includeLockMenuItem = checked;
                    settings.sync();

                }

            }

            TextSwitch {

                id: skipVaultScreenSwitch
                text: "Bypass Vaults page on sign-in"
                checked: settings.skipVaultScreen
                automaticCheck: false

                onClicked: {

                    checked = !checked;
                    settings.skipVaultScreen = checked;
                    settings.sync();

                }

            }

            ComboBox {

                id: allItemsOrOneCategory
                label: qsTr("List")
                width: parent.width
                currentIndex: settings.whichItemsToLoadIndex
                enabled: skipVaultScreenSwitch.checked

                menu: ContextMenu {

                    Repeater {

                        model: allItemsOrOneCategoryModel

                        MenuItem {

                            text: categoryDisplayName

                            onClicked: {

                                if (index === 0) settings.loadAllItems = true;
                                else settings.loadAllItems = false;
                                settings.whichItemsToLoad = categoryName
                                settings.whichItemsToLoadIndex = index;
                                settings.sync();

                            }

                        }

                    }

                }

            }

            TextSwitch {

                text: qsTr("Display one-time passwords on cover") // self explanitory
                //description: "Display an item's one-time password on the home screen's app cover."
                id: otpOnAppCover
                checked: settings.otpOnCover
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.otpOnCover = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("Command-Line Tool")

            }

            Row {

                width: updateButton.width
                height: updateButton.height + (Theme.paddingMedium * 2)
                spacing: 0
                x: (page.width - updateButton.width) * 0.5

                Button {

                    text: qsTr("Check for CLI Update")
                    id: updateButton
                    y: Theme.paddingMedium
                    preferredWidth: Theme.buttonWidthLarge

                    BusyIndicator {

                        id: updatingIndicator
                        size: BusyIndicatorSize.Medium
                        anchors.centerIn: parent
                        running: false

                    }

                    onClicked: {

                        updateCLI.start("op", ["update"]);

                    }

                }

            }

            Row {

                width: parent.width - (Theme.horizontalPageMargin * 2)
                spacing: 0
                x: Theme.horizontalPageMargin
                id: updateLabelsRow
                visible: false

                Column {

                    spacing: Theme.paddingMedium
                    width: parent.width

                    Row {

                        id: updateInitialResponseRow
                        visible: false
                        spacing: 0
                        width: parent.width

                        Label {

                            id: updateResponseLabel
                            width: parent.width
                            leftPadding: Theme.horizontalPageMargin
                            rightPadding: Theme.horizontalPageMargin
                            topPadding: Theme.paddingLarge
                            bottomPadding: Theme.paddingSmall
                            font.pixelSize: Theme.fontSizeExtraSmall
                            linkColor: Theme.highlightColor
                            wrapMode: Text.Wrap

                            BackgroundItem {

                                Rectangle {

                                    height: updateResponseLabel.height
                                    width: updateResponseLabel.width
                                    color: Theme.primaryColor
                                    opacity: 0.15
                                    radius: 30

                                }

                            }

                            Text {

                                textFormat: Text.AutoText

                            }

                            MouseArea {

                                anchors.fill: parent

                                onClicked: { // if there's an update ready, release notes link will be part of text

                                    if (updateAvailable) Qt.openUrlExternally(releaseNotesURL);

                                }

                            }

                        }

                    }

                    Row { // just here incase download takes longer than 45 seconds and explanation required.

                        id: updateDownloadStatusRow
                        visible: false
                        spacing: 0
                        width: parent.width

                        Label {

                            id: updateDownloadStatusLabel
                            width: parent.width
                            leftPadding: Theme.horizontalPageMargin
                            rightPadding: Theme.horizontalPageMargin
                            topPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.Wrap
                            text: qsTr("Downloading...")

                            Text {

                                textFormat: Text.StyledText

                            }

                        }

                    }

                    Row {

                        id: updateDownloadCompletedRow
                        visible: false
                        spacing: 0
                        width: parent.width

                        Label {

                            id: updateDownloadCompletedLabel
                            width: parent.width
                            leftPadding: Theme.horizontalPageMargin
                            rightPadding: Theme.horizontalPageMargin
                            topPadding: Theme.paddingLarge
                            bottomPadding: Theme.paddingSmall
                            font.pixelSize: Theme.fontSizeExtraSmall
                            textFormat: Text.AutoText
                            wrapMode: Text.Wrap

                            BackgroundItem {

                                Rectangle {

                                    height: updateDownloadCompletedLabel.height
                                    width: updateDownloadCompletedLabel.width
                                    color: Theme.primaryColor
                                    opacity: 0.15
                                    radius: 30

                                }

                            }

                            //Text {



                            //}

                            MouseArea {

                                anchors.fill: parent

                                onClicked: { // copy file path

                                    Clipboard.text = updateFilePath;
                                    processStatus.previewSummary = qsTr("Copied file path to clipboard");
                                    processStatus.publish();

                                }

                            }

                        }

                    }

                    Row {

                        id: furtherActionRow
                        visible: false
                        spacing: 0
                        width: parent.width

                        Label {

                            id: furtherActionLabel
                            width: parent.width
                            topPadding: Theme.paddingLarge
                            font.pixelSize: Theme.fontSizeSmall
                            wrapMode: Text.Wrap
                            text: qsTr("<p>Extract, verify and move updated tool to complete installation. More info @ <a href=\"https://developer.1password.com/docs/cli/get-started\">1Password Support</a></p>")
                            linkColor: Theme.highlightColor

                            Text {

                                textFormat: Text.StyledText

                            }

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://developer.1password.com/docs/cli/get-started");

                            }

                        }

                    }

                }

            }

            Row {

                width: accountsButton.width
                height: accountsButton.height + (Theme.paddingMedium * 2)
                x: (page.width - accountsButton.width) * 0.5

                Button {

                    text: qsTr("List CLI Accounts");
                    id: accountsButton
                    y: Theme.paddingMedium
                    preferredWidth: Theme.buttonWidthLarge

                    onClicked: {

                        if (text === qsTr("List CLI Accounts")) {

                            listAccounts.start("op", ["account", "list"]);
                            text = qsTr("Hide Account List");
                            accountsLabelRow.visible = true;

                        }

                        else {

                            text = qsTr("List CLI Accounts");
                            accountsLabel.text = "";
                            accountsLabelRow.visible = false;

                        }

                    }

                }

            }

            Row {

                width: parent.width - (Theme.horizontalPageMargin * 2)
                spacing: 0
                x: Theme.horizontalPageMargin
                id: accountsLabelRow
                visible: false

                Label {

                    id: accountsLabel
                    width: parent.width
                    leftPadding: Theme.horizontalPageMargin
                    rightPadding: Theme.horizontalPageMargin
                    topPadding: Theme.paddingLarge
                    bottomPadding: Theme.paddingMedium
                    font.pixelSize: Theme.fontSizeExtraSmall
                    wrapMode: Text.Wrap

                    BackgroundItem {

                        Rectangle {

                            height: accountsLabel.height
                            width: accountsLabel.width
                            color: Theme.primaryColor
                            opacity: 0.15
                            radius: 30

                        }

                    }

                    Text {

                        textFormat: Text.AutoText

                    }

                }

            }

            Row {

                id: paddingRow
                width: parent.width
                height: Theme.paddingLarge
                //visible: !accountsLabelRow.visible

            }
/* -- experiencing issues with account forget or signout --forget commands not working as expected and user still being able to sign in after these. will need to remove via terminal and/or account page on web.
            Row {

                id: signoutAndForgetLabelRow
                width: parent.width
                x: Theme.horizontalPageMargin

                Label {

                    id: signoutAndForgetLabel
                    text: "Click below to revoke the app's ability to interface with the CLI. Please note current session must be active for command to take effect. Future use of the app will require first re-adding the 'quaycentsfos' shorthand with your account to the CLI.\n"
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    width: page.width - (Theme.horizontalPageMargin * 2)

                }

            }

            Row {

                width: parent.width
                //width: signoutAndForget.width
                //height: signoutAndForget.height + (Theme.paddingMedium * 2)
                //x: (page.width - signoutAndForget.width) * 0.5

                ButtonLayout {

                    Button {

                        text: qsTr("Signout & Forget");
                        id: signoutAndForget
                        y: Theme.paddingMedium
                        preferredWidth: Theme.buttonWidthLarge

                        BusyIndicator {

                            id: removingAccountIndicator
                            size: BusyIndicatorSize.Medium
                            anchors.centerIn: parent
                            running: false

                        }

                        onClicked: {

                            removingAccountIndicator.running = true;
                            errorReadout = "";
                            sessionExpiryTimer.stop();
                            totpModel.clear();
                            totpModel.set(0, {"active": false});
                            mainTotpTimer.stop();
                            // if user's session no longer active--e.g. settings page left open for over 30 mins, will first sign out and then use 'op account forget' command to ensure expected result.
                            signOutProcess.start("op", ["signout", "--forget"]);
                            signOutProcess.waitForFinished();

                            if (signOutProcess.exitStatus() === 0 && errorReadout === "") {

                                itemDetailsModel.clear();
                                itemListModel.clear();
                                vaultListModel.clear();

                                removingAccountIndicator.running = false;
                                processStatus.expireTimeout = 2000;
                                processStatus.previewSummary = "Signout using '--forget' flag was successful.";
                                processStatus.publish();
                                pageStack.clear();
                                pageStack.push(Qt.resolvedUrl("pages/SignIn.qml"), null, PageStackAction.Immediate);

                                /*
                                signOutProcess.start("op", ["account", "forget", "quaycentsfos"]);
                                signOutProcess.waitForFinished();

                                if (signOutProcess.exitStatus() === 0 && errorReadout === "") {

                                    removingAccountIndicator.running = false;
                                    processStatus.expireTimeout = 2000;
                                    processStatus.previewSummary = "QuayCentral access to CLI has been revoked.";
                                    processStatus.publish();
                                    pageStack.clear();
                                    pageStack.push(Qt.resolvedUrl("pages/SignIn.qml"), null, PageStackAction.Immediate);

                                }

                                else {

                                    removingAccountIndicator.running = false;
                                    Clipboard.text = errorReadout;
                                    processStatus.previewSummary = "Error when removing shorthand. Error output copied to clipboard.";
                                    processStatus.publish();

                                }
                                * /

                            }

                            else {

                                removingAccountIndicator.running = false;
                                Clipboard.text = errorReadout;
                                processStatus.previewSummary = "Error when signing out. Error output copied to clipboard.";
                                processStatus.publish();

                            }

                        }

                    }

                }

            }

            Row { // padding row

                width: parent.width
                height: Theme.paddingLarge

            }
*/
        }

    }

    Process {

        id: versionCheck

        onReadyReadStandardOutput: {

            cliVersion = readAllStandardOutput();
            cliVersion = cliVersion.trim();

        }

    }

    Process {

        id: listAccounts

        onReadyReadStandardOutput: {

            var listOfAccounts = readAllStandardOutput();
            accountsLabel.text = "<pre>" + listOfAccounts + "</pre>";

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            errorReadout = errorReadout.trim();
            Clipboard.text = errorReadout;
            processStatus.previewSummary = qsTr("Error when listing accounts. Copied description to clipboard.");
            processStatus.publish();
            errorReadout = "";

        }

    }

    Process {

        id: updateCLI

        onReadyReadStandardOutput: {

            standardOutput = readAllStandardOutput();
            standardOutput = standardOutput.trim();

            if (standardOutput.indexOf("using the latest") !== -1) {

                updateButton.enabled = false;
                updateResponseLabel.text = "<pre>" + standardOutput + "</pre>";
                updateLabelsRow.visible = true;
                updateInitialResponseRow.visible = true;

            }

            else if (standardOutput.indexOf("complete") !== -1) {

                updateFilePath = standardOutput.slice(standardOutput.indexOf("/"));
                updatingIndicator.running = false;
                updateDownloadTimer.stop();
                processStatus.previewSummary = qsTr("Download complete");
                processStatus.publish();
                updateDownloadCompletedLabel.text = "<pre>" + standardOutput + "</pre>";
                updateDownloadCompletedRow.visible = true;
                furtherActionRow.visible = true;

            }
/*
            else if (standardOutput.indexOf("Accounts on this") !== -1) {

                accountsLabel.text = "<pre>" + standardOutput + "</pre>";

            }
*/
            else if (standardOutput.indexOf("is now available") !== -1) {

                updateButton.enabled = false;
                updateAvailable = true;
                releaseNotesURL = standardOutput.slice(standardOutput.indexOf("<") + 1, standardOutput.indexOf(">"));
                updateResponseLabel.text = "<pre>" + standardOutput.slice(0, standardOutput.indexOf("<")) + "<a href=\"" + releaseNotesURL + "\">" + releaseNotesURL + "</a></pre>";
                updateLabelsRow.visible = true;
                updateInitialResponseRow.visible = true;

            }

            else {

                Clipboard.text = standardOutput;
                updateResponseLabel.text = qsTr("Error: QuayCentral is unable to process CLI response.");

            }

            standardOutput = "";

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            errorReadout = errorReadout.trim();

            if (errorReadout.indexOf("Download the update") !== -1) {

                updateAvailable = true;

            }

            else {

                Clipboard.text = errorReadout;
                processStatus.previewSummary = qsTr("Error when updating. Copied description to clipboard.");
                processStatus.publish();

            }

            errorReadout = "";

        }

    }

    Notification {

        id: processStatus
        isTransient: true
        expireTimeout: 1000

    }

    Timer { // if update installer (so far just a few MBs) isn't done in 45 seconds, will notify user and let it continue in background.

        id: updateDownloadTimer
        interval: 45000

        onTriggered: { // notify that download should continue etc.

            updateButton.enabled = false;
            updatingIndicator.running = false;
            updateDownloadStatusLabel.text = updateDownloadStatusLabel.text + qsTr("\n\nDownload has taken longer than 45 seconds. Please check Downloads folder for completed ZIP file or check network & relaunch app to try again, if download has failed.");
            updateDownloadStatusRow.visible = true;
            processStatus.previewSummary = qsTr("Downloading of update still in progress");
            processStatus.publish();

        }

    }

}
