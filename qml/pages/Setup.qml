import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0
import Nemo.Notifications 1.0
import Process 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool shorthandAdded
    property bool haveSessionKey
    property bool cliInstalled

    Component.onCompleted: {

        recheckInstallation.start("op", ["--version"]);
        installationCheckTimer.start();

    }

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height

        Column {

            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {

                title: qsTr("Setup")

            }

            SectionHeader {

                text: qsTr("CLI Installation")

            }

            Label {

                id: recheckInstallationLabel
                color: Theme.highlightColor
                width: parent.width - (Theme.horizontalPageMargin * 2)
                x: Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                horizontalAlignment: "AlignLeft"
                bottomPadding: Theme.paddingLarge

            }

            Label {

                id: cliCheckLabel
                width: parent.width - (Theme.horizontalPageMargin * 2)
                x: Theme.horizontalPageMargin
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                horizontalAlignment: "AlignLeft"
                bottomPadding: recheckInstallButton.visible ? Theme.paddingLarge : 0
                onLinkActivated: Qt.openUrlExternally(link)

            }

            ButtonLayout {

                width: parent.width

                Button {

                    id: downloadRpmButton
                    visible: false
                    text: qsTr("Download Latest CLI RPM")

                    onClicked: {

                        // get the latest RPM from permanent link (not working with the arm installer so only presented as an option if user is on aarch64
                        Qt.openUrlExternally("https://downloads.1password.com/linux/rpm/stable/aarch64/1password-cli-latest.aarch64.rpm");

                    }

                }

                Button {

                    id: recheckInstallButton
                    visible: false
                    text: qsTr("Re-check CLI Installation");

                    onClicked: {

                        recheckInstallationLabel.visible = false;
                        cliCheckLabel.visible = false;
                        pageBusyLabel.text = qsTr("Checking for CLI installation...");
                        pageBusyLabel.running = true;
                        installationCheckTimer.start();
                        visible = false;
                        recheckInstallation.start("op", ["--version"]);

                    }

                }

            }

            SectionHeader {

                id: cliAccessHeader
                text: qsTr("QuayCentral CLI Access")
                visible: false

            }

            Label {

                id: checkShorthandLabel
                visible: false
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                width: parent.width - (Theme.horizontalPageMargin * 2)
                x: Theme.horizontalPageMargin
                horizontalAlignment: "AlignLeft"
                wrapMode: Text.WordWrap
                bottomPadding: Theme.paddingLarge
                textFormat: Text.RichText

            }

            TextField {

                id: emailTextField
                x: Theme.horizontalPageMargin
                width: parent.width - (Theme.horizontalPageMargin * 2)
                label: qsTr("Email")
                visible: false
                inputMethodHints: Qt.ImhEmailCharactersOnly

            }

            TextField {

                id: domainTextField
                x: Theme.horizontalPageMargin
                width: parent.width - (Theme.horizontalPageMargin * 2)
                label: qsTr("Domain")
                visible: false
                inputMethodHints: Qt.ImhUrlCharactersOnly

            }

            TextField {

                id: secretKeyTextField
                x: Theme.horizontalPageMargin
                width: parent.width - (Theme.horizontalPageMargin * 2)
                label: qsTr("Secret Key")
                visible: false
                inputMethodHints: Qt.ImhPreferUppercase

            }

            PasswordField {

                id: masterPasswordTextField
                x: Theme.horizontalPageMargin
                width: parent.width - (Theme.horizontalPageMargin * 2)
                label: qsTr("Master Password")
                visible: false
                passwordMaskDelay: 0

            }

            ButtonLayout {

                Button {

                    id: signinButton
                    text: "Sign-in"
                    visible: false

                    onClicked: {

                        column.visible = false;
                        pageBusyLabel.text = qsTr("Signing in...");
                        pageBusyLabel.running = true;
                        addShorthandAndSignIn.start("op", ["account", "add", "--address", domainTextField.text, "--email", emailTextField.text, "--secret-key", secretKeyTextField.text, "--shorthand", "quaycentsfos", "--signin", "--raw"]);
                        emailTextField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                        emailTextField.text = "";
                        domainTextField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                        domainTextField.text = "";
                        secretKeyTextField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                        secretKeyTextField.text = "";
                        addShorthandAndSignIn.write(masterPasswordTextField.text + "\n");
                        masterPasswordTextField.text = "0000000000000000000000000000000000000000000000000000000000000000";
                        masterPasswordTextField.text = "";

                    }

                }

            }

            Row {

                id: paddingRow
                width: parent.width
                height: Theme.paddingLarge

            }

        }

    }

    Process {

        id: recheckInstallation

        onReadyReadStandardOutput: {

            installationCheckTimer.stop();
            cliVersion = readAllStandardOutput();
            cliVersion = cliVersion.trim();
            recheckInstallationLabel.text = qsTr("Version %1 of the 1Password CLI is installed on your device.").arg(cliVersion);
            recheckInstallationLabel.visible = true;
            downloadRpmButton.visible = false;
            recheckInstallButton.visible = false;
            cliInstalled = true;
            // check for shorthand
            cliAccessHeader.visible = true;
            checkShorthandLabel.visible = true;
            pageBusyLabel.text = qsTr("Checking for QuayCentral CLI access...");
            shorthandCheck.start("op", ["account", "list", "--format", "json"]);

        }

        onReadyReadStandardError: {

            // CLI not yet installed
            installationCheckTimer.stop();
            pageBusyLabel.running = false;
            recheckInstallationLabel.text = qsTr("Unable to detect 1Password CLI on this device.");
            recheckInstallationLabel.visible = true;
            cliInstalled = false;

            if (runningOnAarch64) {

                // show button to download directly from 1password website.
                // permanent link for latest version of the CLI for the aarch64 architecture is:
                // https://downloads.1password.com/linux/rpm/stable/aarch64/1password-cli-latest.aarch64.rpm
                // taken from:
                // https://developer.1password.com/docs/cli/get-started
                // In section: 'Step 1: Install 1Password CLI' -> Linux -> YUM
                cliCheckLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("Clicking below will download the latest RPM (installer) from the 1Password site directly and tapping on the download notification should present an option to install. Alternatively, follow instructions @ <a href='https://developer.1password.com/docs/cli/get-started/'>1Password Developer</a> to download and install the CLI outside of this app.");
                downloadRpmButton.visible = true;

            }

            else cliCheckLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("Please follow instructions @ <a href='https://developer.1password.com/docs/cli/get-started/'>1Password Developer</a> to download and install the CLI, then re-check installation.");
            cliCheckLabel.visible = true;
            recheckInstallButton.visible = true;

        }

    }

    Process {

        id: shorthandCheck

        onReadyReadStandardOutput: {

            if (haveSessionKey) {

                sessionExpiryTimer.restart();
                var prelimOutput = readAllStandardOutput();
                var vaultList = JSON.parse(prelimOutput);
                vaultListModel.clear();

                if (vaultList.length === 1) justOneVault = true;

                else {

                    justOneVault = false;
                    vaultListModel.append({"name": "All Vaults", "uuid": "ALL_VAULTS", "categories": categoryListModel});

                }

                for (var i = 0; i < vaultList.length; i++) {

                    vaultListModel.append({"name": vaultList[i].name, "uuid": vaultList[i].id,
                    "categories": categoryListModel});

                }

                pageBusyLabel.running = false;
                checkShorthandLabel.text = "";
                pageStack.replace(Qt.resolvedUrl("Vaults.qml"));

            }

            else {

                pageBusyLabel.running = false;
                waitForFinished();
                const listOfAccounts = readAllStandardOutput();
                var parsedListOfAccounts = JSON.parse(listOfAccounts);
                shorthandAdded = false;

                for (var i = 0; i < parsedListOfAccounts.length; i++) {

                    if (parsedListOfAccounts[i].shorthand === "quaycentsfos") shorthandAdded = true;

                }

                if (shorthandAdded == false) {

                    checkShorthandLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("QuayCentral is currently unable to utilize the CLI. Please sign in below to add the 'quaycentsfos' shorthand. Alternatively, manually add via Terminal [op account add --shorthand quaycentsfos]. Instructions @ <a href='https://developer.1password.com/docs/cli/sign-in-manually/#set-a-custom-account-shorthand'>1Password Developer</a>.");
                    emailTextField.visible = true;
                    domainTextField.visible = true;
                    secretKeyTextField.visible = true;
                    masterPasswordTextField.visible = true;
                    signinButton.visible = true;

                }

                else {

                    checkShorthandLabel.text = qsTr("QuayCentral can access the CLI using shorthand 'quaycentsfos'. Please swipe back to sign-in.");

                }

            }

        }

        onReadyReadStandardError: {

            if (haveSessionKey) {

                console.log("Error when gathering Vaults after successful sign-in.");

            }

            else {

                pageBusyLabel.running = false;
                errorReadout = readAllStandardError();
                errorReadout = errorReadout.trim();
                Clipboard.text = errorReadout;
                processStatus.previewSummary = qsTr("Error when listing accounts. Copied description to clipboard.");
                processStatus.publish();
                errorReadout = "";

            }

        }

    }

    Process {

        id: addShorthandAndSignIn

        onReadyReadStandardOutput: {

            if (haveSessionKey) {

                sessionExpiryTimer.restart();
                var prelimOutput = readAllStandardOutput();
                var vaultList = JSON.parse(prelimOutput);
                vaultListModel.clear();

                if (vaultList.length === 1) justOneVault = true;

                else {

                    justOneVault = false;
                    vaultListModel.append({"name": "All Vaults", "uuid": "ALL_VAULTS", "categories": categoryListModel});

                }

                for (var i = 0; i < vaultList.length; i++) {

                    vaultListModel.append({"name": vaultList[i].name, "uuid": vaultList[i].id,
                    "categories": categoryListModel});

                }

                pageBusyLabel.running = false;
                checkShorthandLabel.text = "";
                pageStack.replace(Qt.resolvedUrl("Vaults.qml"));

            }

            else {

                currentSession = readAllStandardOutput();
                currentSession = currentSession.trim();
                haveSessionKey = true;
                appPastLaunch = true;
                settings.skipVaultScreen = false; // resetting some settings incase app was previously used prior to cli deleted and/or access removed with settings still saved.
                settings.loadFavItems = false;
                settings.sync();
                anyFavItems = false;
                pageBusyLabel.text = qsTr("Listing vaults...");
                shorthandCheck.start("op", ["vault", "list", "--format", "json", "--session", currentSession]);

            }

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            console.log("Error as follows:\n" + errorReadout);
            processStatus.previewSummary = qsTr("Unknown error when signing in - %1").arg(errorReadout);
            processStatus.publish();
            pageBusyLabel.running = false;
            column.visible = true;

        }

    }

    Notification {

        id: processStatus
        isTransient: true
        expireTimeout: 1000

    }

    BusyLabel {

        id: pageBusyLabel
        anchors.centerIn: parent
        running: true
        text: qsTr("Checking for CLI installation...");

    }

    Timer {

        id: installationCheckTimer
        interval: 3000
        repeat: false

        onTriggered: { // waiting 3 seconds for response from CLI.

            // CLI not yet installed
            recheckInstallationLabel.text = qsTr("No installation of the 1Password CLI was found on this device.");
            cliInstalled = false;
            pageBusyLabel.running = false;

            if (runningOnAarch64) {

                // show button to download directly from 1password website.
                // permanent link for latest version of the CLI for the aarch64 architecture is:
                // https://downloads.1password.com/linux/rpm/stable/aarch64/1password-cli-latest.aarch64.rpm
                // taken from:
                // https://developer.1password.com/docs/cli/get-started
                // In section: 'Step 1: Install 1Password CLI' -> Linux -> YUM

                cliCheckLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("Clicking below will download the latest RPM (installer) from the 1Password site directly and tapping on the download notification should present an option to install. Alternatively, follow instructions @ <a href='https://developer.1password.com/docs/cli/get-started/'>1Password Developer</a> to download and install the CLI outside of this app.");
                downloadRpmButton.visible = true;

            }

            else cliCheckLabel.text = "<style>a{color:" + Theme.primaryColor + ";}</style>" + qsTr("Please follow instructions @ <a href='https://developer.1password.com/docs/cli/get-started/'>1Password Developer</a> to download and install the CLI, then re-check installation.");
            recheckInstallationLabel.visible = true;
            cliCheckLabel.visible = true;
            recheckInstallButton.visible = true;

        }

    }

}
