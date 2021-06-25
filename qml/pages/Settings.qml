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

        // checking for version so that text in 'About' is as up-to-date as we can have it. Avoiding any discrepancy between that
        // and output from 'Update CLI' button.
        versionCheck.start("op", ["--version"]);

    }

    onUpdateAvailableChanged: {

        if (updateAvailable) {

            updateCLI.write("y\n");
            updatingIndicator.running = true;
            updateDownloadTimer.start();
            processStatus.previewSummary = qsTr("Downloading Update...");
            processStatus.publish();

        }

    }

    // was to be used for option on this page to signout and forget the --quaycentsfos shorthand, ran into issues
    // with user having to get into terminal, and also possibly list of authorized devices online, to remove anyway, nullifying
    // purpose of the option being included here.
    // property bool signOutError: false


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

            Label {

                id: pressAndHoldInfoLabel
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width
                text: tappingCombo.currentIndex === 1 ? qsTr("Long press will load item details") : qsTr("Long press will copy password")
                wrapMode: Text.Wrap
                leftPadding: Theme.horizontalPageMargin

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
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.ccnumHidden = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("Login Session")

            }

            TextSwitch {

                text: qsTr("Enable Lockout Timer")
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

                label: qsTr("Lock when CLI inactive for")
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
                enabled: enableTimerSwitch.checked
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.sessionExpiryNotify = checked;
                    settings.sync();

                }

            }

            SectionHeader {

                text: qsTr("Layout")

            }

            TextSwitch {

                text: qsTr("Show 'Lock' menu on every screen")
                id: showLockMenuItemSwitch
                checked: settings.includeLockMenuItem
                leftMargin: Theme.horizontalPageMargin

                onCheckedChanged: {

                    settings.includeLockMenuItem = checked;
                    settings.sync();

                }

            }

            Label {

                id: noLockMenuInfoLabel
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width
                visible: !showLockMenuItemSwitch.checked
                text: "Use padlock on cover or swipe back to sign-in screen."
                wrapMode: Text.Wrap
                leftPadding: Theme.horizontalPageMargin
                rightPadding: Theme.horizontalPageMargin

            }

            SectionHeader {

                text: qsTr("Command-Line Tool")

            }

            Row {

                width: updateButton.width
                height: updateButton.height + (Theme.paddingLarge * 2)
                spacing: 0
                x: (page.width - updateButton.width) * 0.5

                Button {

                    text: qsTr("Update CLI")
                    id: updateButton
                    y: Theme.paddingLarge

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

                            Text {

                                textFormat: Text.AutoText

                            }

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
                            text: qsTr("<p>Extract, verify and move updated tool to complete installation. More info @ <a href=\"https://support.1password.com/command-line-getting-started/#set-up-the-command-line-tool\">1Password Support</a></p>")

                            Text {

                                textFormat: Text.StyledText

                            }

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://support.1password.com/command-line-getting-started/#set-up-the-command-line-tool");

                            }

                        }

                    }

                }

            }

            Row {

                width: accountsButton.width
                height: accountsButton.height + (Theme.paddingLarge * 2)
                // spacing: Theme.paddingMedium
                x: (page.width - accountsButton.width) * 0.5

                Button {

                    text: qsTr("CLI Accounts");
                    id: accountsButton
                    y: Theme.paddingLarge

                    onClicked: {

                        if (text === qsTr("CLI Accounts")) {

                            updateCLI.start("op", ["signin", "--list"]);
                            text = qsTr("Hide Accounts");
                            accountsLabelRow.visible = true;

                        }

                        else {

                            text = qsTr("CLI Accounts");
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
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("A GUI app for the 1Password command-line tool on Sailfish OS.\n\nBy Michael J. Barrett\n\nVersion 0.3\nLicensed under GNU GPLv3\n\nQuayCentral is an unofficial application and is in no way associated with 1Password or AgileBits, Inc.\n\nVersion %1 of the 1Password command-line tool is installed on your device.").arg(cliVersion);
                            bottomPadding: Theme.paddingLarge

                        }

                    }

                    Row {

                        width: buyMeCoffeeLabel.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: buyMeCoffeeLabel.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            id: buyMeCoffeeLabel
                            font.pixelSize: Theme.fontSizeTiny
                            font.letterSpacing: 2
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("SUPPORT APP DEVELOPMENT")
                            bottomPadding: Theme.paddingMedium

                        }

                    }
/*
                    Row {

                        width: parent.width * 0.6
                        x: parent.width * 0.2
                        spacing: 0
                        height: linkToBMAC.height

                        Image {

                            id: linkToBMAC
                            source: Theme.colorScheme == Theme.DarkOnLight ? "BMClogowithwordmark-black.png" : "BMClogowithwordmark-white.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.buymeacoffee.com/michaeljb");

                            }

                        }

                    }

                    Row {

                        width: parent.width * 0.5
                        x: parent.width * 0.25
                        spacing: 0
                        height: Theme.paddingMedium * 3

                        Separator {

                            width: parent.width
                            y: (Theme.paddingMedium * 1.5) - (this.height * 0.5)
                            horizontalAlignment: Separator.Center
                            color: Theme.primaryColor

                        }

                    }
*/

/*
                    Row {

                        width: buyMeCoffeeLabel2.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        height: buyMeCoffeeLabel2.height
                        spacing: 0

                        Label {

                            topPadding: Theme.paddingLarge
                            id: buyMeCoffeeLabel2
                            font.pixelSize: Theme.fontSizeExtraSmall
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("-or-")
                            bottomPadding: Theme.paddingMedium

                        }

                    }
*/
                    Row {

                        id: linkToBMAC2Row
                        width: parent.width * 0.6
                        x: parent.width * 0.2
                        spacing: 0
                        height: linkToBMAC2.height + (Theme.paddingMedium * 2) //linkToBMAC.height

                        Image {

                            id: linkToBMAC2
                            source: Theme.colorScheme == Theme.DarkOnLight ? "SupportMe_dark@2x.png" : "SupportMe_yellow@2x.png"
                            fillMode: Image.PreserveAspectFit
                            width: parent.width
                            y: Theme.paddingMedium // (linkToBMAC.height - this.paintedHeight) * 0.5

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("https://www.ko-fi.com/michaeljb");

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
                            id: sendFeedbackLabel
                            font.pixelSize: Theme.fontSizeTiny
                            font.letterSpacing: 2
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("SEND FEEDBACK")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        spacing: 0
                        height: linkToBMAC2Row.height
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
                                onClicked: Qt.openUrlExternally("mailto:mjbdev@eml.cc?subject=QuayCentral Feedback");

                            }

                        }

                        Label {

                            id: feedbackEmail
                            height: parent.height
                            font.pixelSize: Theme.fontSizeLarge
                            color: Theme.primaryColor
                            text: "mjbdev@eml.cc"
                            font.bold: true
                            topPadding: 0
                            bottomPadding: this.paintedHeight * 0.1 // making this adjustment to keep vertically centered look with lowercase email.
                            leftPadding: Theme.paddingSmall
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {

                                anchors.fill: parent
                                onClicked: Qt.openUrlExternally("mailto:mjbdev@eml.cc?subject=QuayCentral Feedback");

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
                            font.pixelSize: Theme.fontSizeTiny
                            font.letterSpacing: 2
                            color: Theme.highlightColor
                            wrapMode: Text.Wrap
                            text: qsTr("VIEW SOURCE")
                            bottomPadding: Theme.paddingMedium

                        }

                    }

                    Row {

                        width: linkToGitHub.paintedWidth
                        x: (parent.width - this.width) * 0.5
                        spacing: 0
                        height: linkToBMAC2Row.height

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

        } // alreay signed-in to the app so there shouldn't be any error with just gathering version number.

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
                updateButton.enabled = false;
                updateDownloadCompletedLabel.text = "<pre>" + standardOutput + "</pre>";
                updateDownloadCompletedRow.visible = true;
                furtherActionRow.visible = true;

            }

            else if (standardOutput.indexOf("Accounts on this") !== -1) {

                accountsLabel.text = "<pre>" + standardOutput + "</pre>";

            }

            else if (standardOutput.indexOf("is now available") !== -1) {

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

    BusyIndicator {

        id: updatingIndicator
        size: BusyIndicatorSize.Medium
        anchors.centerIn: updateResponseLabel
        running: false

    }

    Timer { // if update installer (so far just a few MBs) isn't done in 45 seconds, will notify user and let it continue in background.

        id: updateDownloadTimer
        interval: 45000

        onTriggered: {

            // notify that download should continue etc.
            updateButton.enabled = false;
            updatingIndicator.running = false;
            updateDownloadStatusLabel.text = updateDownloadStatusLabel.text + qsTr("\n\nDownload has taken longer than 45 seconds. Please check Downloads folder for completed ZIP file or check network & relaunch app to try again, if download has failed.");
            updateDownloadStatusRow.visible = true;
            processStatus.previewSummary = qsTr("Download of update still in progress");
            processStatus.publish();

        }

    }

}
