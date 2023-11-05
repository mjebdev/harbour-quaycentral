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

        if (!justOneVault && settings.skipVaultScreen) {

            // determine current index of default vault combo by confirming its place in current list of vaults.
            for (var i = 0; i < vaultListModel.count; i++) {

                if (settings.defaultVaultUuid === vaultListModel.get(i).uuid) {

                    defaultVaultCombo.currentIndex = i;

                }

            }

        }

    }

    onUpdateAvailableChanged: {

        if (updateAvailable) {

            if (runningOnAarch64) { // grab latest RPM from 1Password site. Option in settings for this as opposed to zip file to be moved manually?

                updateCLI.write("n\n");
                processStatus.previewSummary = qsTr("Downloading latest RPM...");
                processStatus.publish();
                Qt.openUrlExternally("https://downloads.1password.com/linux/rpm/stable/aarch64/1password-cli-latest.aarch64.rpm");

            }

            else {

                updateCLI.write("y\n");
                updatingIndicator.running = true;
                updateDownloadTimer.start();
                processStatus.previewSummary = qsTr("Downloading update in ZIP format...");
                processStatus.publish();

            }

        }

    }

    ListModel {

        id: allItemsOrOneCategoryModel

        ListElement {categoryName: ""; categoryDisplayName: qsTr("All Categories")}
        ListElement {categoryName: "Login"; categoryDisplayName: qsTr("Logins")}
        ListElement {categoryName: "Secure Note"; categoryDisplayName: qsTr("Secure Notes")}
        ListElement {categoryName: "Credit Card"; categoryDisplayName: qsTr("Credit Cards")}
        ListElement {categoryName: "Identity"; categoryDisplayName: qsTr("Identities")}
        ListElement {categoryName: "API Credential"; categoryDisplayName: qsTr("API Credentials")}
        ListElement {categoryName: "Bank Account"; categoryDisplayName: qsTr("Bank Accounts")}
        ListElement {categoryName: "Database"; categoryDisplayName: qsTr("Databases")}
        ListElement {categoryName: "Driver License"; categoryDisplayName: qsTr("Driver Licenses")}
        ListElement {categoryName: "Email Account"; categoryDisplayName: qsTr("Email Accounts")}
        ListElement {categoryName: "Membership"; categoryDisplayName: qsTr("Memberships")}
        ListElement {categoryName: "Outdoor License"; categoryDisplayName: qsTr("Outdoor Licenses")}
        ListElement {categoryName: "Passport"; categoryDisplayName: qsTr("Passports")}
        ListElement {categoryName: "Password"; categoryDisplayName: qsTr("Passwords")}
        ListElement {categoryName: "Reward Program"; categoryDisplayName: qsTr("Reward Programs")}
        ListElement {categoryName: "Server"; categoryDisplayName: qsTr("Servers")}
        ListElement {categoryName: "Social Security Number"; categoryDisplayName: qsTr("Social Security Numbers")}
        ListElement {categoryName: "Software License"; categoryDisplayName: qsTr("Software Licenses")}
        ListElement {categoryName: "SSH Key"; categoryDisplayName: qsTr("SSH Keys")}
        ListElement {categoryName: "Wireless Router"; categoryDisplayName: qsTr("Wireless Routers")}

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

                text: qsTr("Item Listing")

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

                text: qsTr("Layout & Navigation")

            }

            TextSwitch {

                id: showLockMenuItemSwitch
                text: qsTr("Include Lock menu on each screen")
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
                text: justOneVault ? qsTr("Bypass Vault page after sign-in") : qsTr("Bypass Vaults page after sign-in")
                checked: settings.skipVaultScreen

                onCheckedChanged: {

                    if (!checked && !justOneVault) {

                        defaultVaultCombo.currentIndex = 0;
                        settings.defaultVaultUuid = "ALL_VAULTS";

                    }

                    settings.skipVaultScreen = checked;
                    settings.sync();

                }

            }

            ComboBox {

                label: qsTr("Default vault")
                id: defaultVaultCombo
                width: parent.width
                enabled: skipVaultScreenSwitch.checked
                visible: !justOneVault

                menu: ContextMenu {

                    Repeater {

                        model: vaultListModel

                        MenuItem {

                            text: name

                            onClicked: {

                                settings.defaultVaultUuid = uuid;
                                settings.sync();

                            }

                        }

                    }

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

            SectionHeader {

                text: qsTr("Cover")

            }

            TextSwitch {

                text: qsTr("Display one-time password on cover")
                description: qsTr("For items that include one, OTP will appear on the app cover.")
                id: otpOnAppCover
                checked: settings.otpOnCover
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.otpOnCover = checked;
                    settings.sync();

                }

            }

            TextSwitch {

                text: qsTr("Show Lock button on cover with OTP")
                description: qsTr("Alternatively, tapping Close button will revert to items page without locking vault.")
                id: lockButtonOnCoverSwitch
                enabled: otpOnAppCover.checked
                checked: settings.lockButtonOnCover
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.lockButtonOnCover = checked;
                    settings.sync;

                }

            }

            SectionHeader {

                text: qsTr("Vaults Page")

            }

            TextSwitch {

                id: loadFavItemsSwitch
                text: qsTr("Show Favorite items on Vaults page");
                description: qsTr("Change takes effect after next sign-in.");
                checked: settings.loadFavItems
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.loadFavItems = checked;
                    settings.sync();

                }

            }

            TextSwitch {

                id: specifyVaultsPageCategoriesSwitch
                text: qsTr("List only selected categories");
                checked: settings.limitedCatsVaultsPage
                automaticCheck: false

                onClicked: {

                    checked = !checked;

                    if (checked) {

                        settings.limitedCatsVaultsPage = true;
                        settings.sync();
                        pageStack.push("SelectCategories.qml");

                    }

                    else {

                        categoryListModel.set(1, {"includeOnVaultsPage": true});
                        categoryListModel.set(2, {"includeOnVaultsPage": true});
                        categoryListModel.set(3, {"includeOnVaultsPage": true});
                        categoryListModel.set(4, {"includeOnVaultsPage": true});
                        categoryListModel.set(5, {"includeOnVaultsPage": true});
                        categoryListModel.set(6, {"includeOnVaultsPage": true});
                        categoryListModel.set(7, {"includeOnVaultsPage": true});
                        categoryListModel.set(8, {"includeOnVaultsPage": true});
                        categoryListModel.set(9, {"includeOnVaultsPage": true});
                        categoryListModel.set(10, {"includeOnVaultsPage": true});
                        categoryListModel.set(11, {"includeOnVaultsPage": true});
                        categoryListModel.set(12, {"includeOnVaultsPage": true});
                        categoryListModel.set(13, {"includeOnVaultsPage": true});
                        categoryListModel.set(14, {"includeOnVaultsPage": true});
                        categoryListModel.set(15, {"includeOnVaultsPage": true});
                        categoryListModel.set(16, {"includeOnVaultsPage": true});
                        categoryListModel.set(17, {"includeOnVaultsPage": true});
                        categoryListModel.set(18, {"includeOnVaultsPage": true});
                        categoryListModel.set(19, {"includeOnVaultsPage": true});
                        settings.vaultPageDisplayApiCredential = true;
                        settings.vaultPageDisplayBankAccount = true;
                        settings.vaultPageDisplayCreditCard = true;
                        settings.vaultPageDisplayDatabase = true;
                        settings.vaultPageDisplayDocument = true;
                        settings.vaultPageDisplayDriverLicense = true;
                        settings.vaultPageDisplayEmailAccount = true;
                        settings.vaultPageDisplayIdentity = true;
                        settings.vaultPageDisplayMembership = true;
                        settings.vaultPageDisplayOutdoorLicense = true;
                        settings.vaultPageDisplayPassport = true;
                        settings.vaultPageDisplayPassword = true;
                        settings.vaultPageDisplayRewardProgram = true;
                        settings.vaultPageDisplaySecureNote = true;
                        settings.vaultPageDisplayServer = true;
                        settings.vaultPageDisplaySocialSecurityNumber = true;
                        settings.vaultPageDisplaySoftwareLicense = true;
                        settings.vaultPageDisplaySshKey = true;
                        settings.vaultPageDisplayWirelessRouter = true;
                        settings.limitedCatsVaultsPage = false;
                        settings.sync();

                    }

                }

            }

            SectionHeader {

                text: qsTr("Command-Line Tool")

            }
// looking to add option to install RPM from permanent latest-version link if on aarch64 (arm RPM does not install) on future version.
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

                    Row { // just here incase download takes longer than one minute and explanation required.

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

                            MouseArea {

                                anchors.fill: parent

                                onClicked: {

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

                            listAccounts.start("op", ["account", "list", "--format", "json"]);
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

                width: parent.width
                height: Theme.paddingLarge

            }

        }

    }

    Process {

        id: listAccounts

        onReadyReadStandardOutput: {

            waitForFinished();
            const listOfAccounts = readAllStandardOutput();
            var parsedListOfAccounts = JSON.parse(listOfAccounts);
            var accountsString = "";

            for (var i = 0; i < parsedListOfAccounts.length; i++) {

                accountsString = accountsString + "URL:\n" + parsedListOfAccounts[i].url + "\nEmail:\n" + parsedListOfAccounts[i].email + "\nShorthand:\n" + parsedListOfAccounts[i].shorthand;
                if ((i + 1) < parsedListOfAccounts.length) accountsString = accountsString + "\n\n";

            }

            accountsLabel.text = "<pre>" + accountsString + "</pre>";

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
                processStatus.previewSummary = qsTr("Error when updating. Description copied to clipboard.");
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

    Timer {

        id: updateDownloadTimer
        interval: 60000

        onTriggered: {

            updateButton.enabled = false;
            updatingIndicator.running = false;
            updateDownloadStatusLabel.text = updateDownloadStatusLabel.text + qsTr("\n\nDownload has taken longer than one minute. Please check Downloads folder for completed ZIP file or check network & relaunch app to try again, if download has failed.");
            updateDownloadStatusRow.visible = true;
            processStatus.previewSummary = qsTr("Downloading of update still in progress");
            processStatus.publish();

        }

    }

}
