import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0
import "pages"

ApplicationWindow {

    id: appWindow
    initialPage: Component { SignIn { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    ConfigurationGroup {

        id: settings
        path: "/apps/harbour-quaycentral"

        property int sessionTimeLength: 120000
        property int sessionTimeIndex: 1
        property int whichItemsToLoadIndex: 0
        property string whichItemsToLoad: ""
        property string defaultVaultUuid
        property bool skipVaultScreen
        property bool tapToCopy
        property bool enterKeyLoadsDetails
        property bool sessionExpiryNotify
        property bool otpOnCover
        property bool enableTimer
        property bool includeLockMenuItem: true
        property bool loadAllItems: true
        property bool loadFavItems
        property bool lockButtonOnCover
        property bool limitedCatsVaultsPage
        property bool downloadToDocs: true
        property bool autoDownloadRpmAarch64: true
        property bool forceOverwriteDocs
        property bool showItemIconsInList: true

        property bool vaultPageDisplayApiCredential: true
        property bool vaultPageDisplayBankAccount: true
        property bool vaultPageDisplayCreditCard: true
        property bool vaultPageDisplayDatabase: true
        property bool vaultPageDisplayDocument: true
        property bool vaultPageDisplayDriverLicense: true
        property bool vaultPageDisplayEmailAccount: true
        property bool vaultPageDisplayIdentity: true
        property bool vaultPageDisplayMembership: true
        property bool vaultPageDisplayOutdoorLicense: true
        property bool vaultPageDisplayPassport: true
        property bool vaultPageDisplayPassword: true
        property bool vaultPageDisplayRewardProgram: true
        property bool vaultPageDisplaySecureNote: true
        property bool vaultPageDisplayServer: true
        property bool vaultPageDisplaySocialSecurityNumber: true
        property bool vaultPageDisplaySoftwareLicense: true
        property bool vaultPageDisplaySshKey: true
        property bool vaultPageDisplayWirelessRouter: true

    }

    property var itemsPageObject
    property int secondsCountdown
    property string chosenCategory
    property string errorReadout
    property string standardOutput
    property string cliVersion
    property string currentSession
    property string categoriesSelected
    property string documentDownloading
    property string documentUploading
    property string itemCategoryListingType
    property bool expiredSession
    property bool appPastLaunch
    property bool justOneVault
    property bool fetchingOtp
    property bool otpDisplayedOnCover
    property bool anyFavItems
    property bool runningOnAarch64
    property bool docsInAllVaults
    property bool downloadFin
    property bool uploadFin
    property bool itemListingFin

    // Testing w/ OTP variables instead of a ListModel

    property string varOtp
    //property string varOtpPart1
    //property string varOtpPart2
    property int varOtpSecondsLeft
    property bool varOtpPrimaryColor: true
    property bool varOtpActive

    ListModel {

        id: largeTypeModel

        ListElement {

            character: ""

        }

    }

    ListModel {

        id: categoryListModel

        ListElement {categoryName: "Login"; categoryDisplayName: qsTr("Logins"); includeOnVaultsPage: true}
        ListElement {categoryName: "API Credential"; categoryDisplayName: qsTr("API Credentials"); includeOnVaultsPage: true}
        ListElement {categoryName: "Bank Account"; categoryDisplayName: qsTr("Bank Accounts"); includeOnVaultsPage: true}
        ListElement {categoryName: "Credit Card"; categoryDisplayName: qsTr("Credit Cards"); includeOnVaultsPage: true}
        ListElement {categoryName: "Database"; categoryDisplayName: qsTr("Databases"); includeOnVaultsPage: true}
        ListElement {categoryName: "Document"; categoryDisplayName: qsTr("Documents"); includeOnVaultsPage: true} // will not be included in the model on Settings as cannot be loaded automatically as with other categories, needs it's own page/list layout.
        ListElement {categoryName: "Driver License"; categoryDisplayName: qsTr("Driver Licenses"); includeOnVaultsPage: true}
        ListElement {categoryName: "Email Account"; categoryDisplayName: qsTr("Email Accounts"); includeOnVaultsPage: true}
        ListElement {categoryName: "Identity"; categoryDisplayName: qsTr("Identities"); includeOnVaultsPage: true}
        ListElement {categoryName: "Membership"; categoryDisplayName: qsTr("Memberships"); includeOnVaultsPage: true}
        ListElement {categoryName: "Outdoor License"; categoryDisplayName: qsTr("Outdoor Licenses"); includeOnVaultsPage: true}
        ListElement {categoryName: "Passport"; categoryDisplayName: qsTr("Passports"); includeOnVaultsPage: true}
        ListElement {categoryName: "Password"; categoryDisplayName: qsTr("Passwords"); includeOnVaultsPage: true}
        ListElement {categoryName: "Reward Program"; categoryDisplayName: qsTr("Reward Programs"); includeOnVaultsPage: true}
        ListElement {categoryName: "Secure Note"; categoryDisplayName: qsTr("Secure Notes"); includeOnVaultsPage: true}
        ListElement {categoryName: "Server"; categoryDisplayName: qsTr("Servers"); includeOnVaultsPage: true}
        ListElement {categoryName: "Social Security Number"; categoryDisplayName: qsTr("Social Security Numbers"); includeOnVaultsPage: true}
        ListElement {categoryName: "Software License"; categoryDisplayName: qsTr("Software Licenses"); includeOnVaultsPage: true}
        ListElement {cateogryName: "SSH Key"; categoryDisplayName: qsTr("SSH Keys"); includeOnVaultsPage: true}
        ListElement {categoryName: "Wireless Router"; categoryDisplayName: qsTr("Wireless Routers"); includeOnVaultsPage: true}

    }

    ListModel {

        id: vaultListModel

        ListElement {

            name: ""; uuid: ""

        }

    }

    ListModel {

        id: itemListModel

        ListElement {

            uuid: ""; title: ""; titleUpperCase: ""; templateUuid: ""; itemVaultId: ""; itemVaultName: ""; iconUrl: "image://theme/icon-m-keys"; iconEmoji: ""; docCreatedAt: ""; docUpdatedAt: ""; docAdditionalInfo: ""

        }

    }

    ListModel {

        id: itemSearchModel

        ListElement {

            uuid: ""; title: ""; titleUpperCase: ""; templateUuid: ""; itemVaultId: ""; itemVaultName: ""; iconUrl: "image://theme/icon-m-keys"; iconEmoji: ""; docCreatedAt: ""; docUpdatedAt: ""; docAdditionalInfo: ""

        }

        function update(searchFieldText) {

            clear();

            for (var i = 0; i < itemListModel.count; i++) {

                if (searchFieldText === "" || itemListModel.get(i).titleUpperCase.indexOf(searchFieldText.toUpperCase()) >= 0) {

                    append(itemListModel.get(i));

                }

            }

        }

    }

    ListModel {

        id: itemDetailsModel

        ListElement {

            itemId: ""; itemType: ""; itemTitle: ""; itemPassword: ""; itemVaultId: ""; itemVaultName: ""; docCreatedAt: ""; docUpdatedAt: ""; docAdditionalInfo: "";

            itemFields: [ ListElement {

                fieldId: "";
                fieldType: "";
                fieldLabel: "";
                fieldValue: "";
                fieldOtp: ""

            }]

        }

    }

    ListModel {

        id: favItemsModel

        ListElement {

            itemId: ""; itemType: ""; itemTitle: ""; itemVaultId: ""; itemVaultName: "";

        }

    }

    Process {

        id: mainUploadDocument

        onReadyReadStandardOutput: {

            uploadFin = true;
            sessionExpiryTimer.restart();
            var uploadConfParsed = JSON.parse(readAllStandardOutput());
            var vaultUploadedTo = "";

            for (var i = 0; i < vaultListModel.count; i++) {

                if (uploadConfParsed.vaultUuid == vaultListModel.get(i).uuid) vaultUploadedTo = vaultListModel.get(i).name;

            }

            notifySessionExpired.previewSummary = qsTr("Upload successful - Document '%1' added to %2 vault. Refreshing Documents list...").arg(documentUploading, vaultUploadedTo);
            notifySessionExpired.publish();

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            sessionExpiryTimer.stop();

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) {

                notifySessionExpired.previewSummary = qsTr("Session Expired");
                notifySessionExpired.publish();
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

            else {

                Clipboard.text = errorReadout;
                notifySessionExpired.previewSummary = qsTr("Unknown error when uploading '%1' to server. Error copied to clipboard.").arg(documentUploading);
                notifySessionExpired.publish();

            }

            uploadFin = true;

        }

    }

    Process {

        id: mainGetDocument

        onReadyReadStandardOutput: {

            var prelimOutput = "";
            prelimOutput = readAllStandardOutput();
            if (prelimOutput.indexOf("Aborting") !== 0) {

                notifySessionExpired.previewSummary = qsTr("Download of '%1' canceled.").arg(documentDownloading);

            }

            else if (prelimOutput == documentDownloading) {

                notifySessionExpired.previewSummary = qsTr("Download of '%1' is complete.").arg(documentDownloading);

            }

            else {

                Clipboard.text = prelimOutput;
                notifySessionExpired.previewSummary = qsTr("QuayCentral is unable to process CLI response. Copied to clipboard.");

            }

            sessionExpiryTimer.restart();
            notifySessionExpired.publish();
            downloadFin = true;

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            sessionExpiryTimer.stop();

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) { // (was - else if - prior to commenting out above)

                notifySessionExpired.previewSummary = qsTr("Session Expired");
                notifySessionExpired.publish();
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

            else if (errorReadout.indexOf("cannot prompt for confirmation") !== 1) { // User has chosen to not force CLI to overwrite so process ends without download being saved.

                sessionExpiryTimer.restart();
                notifySessionExpired.previewSummary = qsTr("File with the name '%1' already exists. Will not overwrite.").arg(documentDownloading);
                notifySessionExpired.publish();
                downloadFin = true;

            }

            else {

                Clipboard.text = errorReadout;
                notifySessionExpired.previewSummary = qsTr("Unknown error when downloading '%1' from server. Error copied to clipboard.").arg(documentDownloading);
                notifySessionExpired.publish();
                downloadFin = true;

            }

        }

        onFinished: { // Can be the case that process will finish without output but completed download.

            if (mainGetDocument.exitStatus() === 0 && errorReadout === "") {

                sessionExpiryTimer.restart();
                notifySessionExpired.previewSummary = qsTr("Download of '%1' is complete.").arg(documentDownloading);
                notifySessionExpired.publish();
                downloadFin = true;

            }

        }

    }

    Process {

        id: mainGetOtp

        onReadyReadStandardOutput: {

            var otpOutput = readAllStandardOutput();
            otpOutput = otpOutput.toString();
            varOtp = otpOutput;
            varOtpPrimaryColor = true;
            sessionExpiryTimer.restart();
            fetchingOtp = false;

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) lockItUp(true);

            else if (errorReadout.indexOf("dial tcp") !== -1) {

                notifySessionExpired.previewSummary = qsTr("Network error when fetching One-Time Password. Please reload item when reconnected.");
                notifySessionExpired.publish();

            }

            else {

                Clipboard.text = errorReadout;
                notifySessionExpired.previewSummary = qsTr("Unknown error fetching One-Time Password (copied to clipboard).");
                notifySessionExpired.publish();

            }

        }

    }

    Process {

        id: signOutProcess
        onReadyReadStandardError: errorReadout = readAllStandardError();

    }

    Timer {

        id: mainOtpTimer
        interval: 500
        repeat: true
        triggeredOnStart: false

        onTriggered: {

            var otpCurrentTime = new Date;
            secondsCountdown = otpCurrentTime.getSeconds();
            if (secondsCountdown > 29) secondsCountdown = secondsCountdown - 30;
            secondsCountdown = (secondsCountdown - 30) * -1;

            if (secondsCountdown === 30 && fetchingOtp === false) {

                fetchingOtp = true;
                varOtpSecondsLeft = 30;
                varOtpPrimaryColor = false;
                mainGetOtp.start("op", ["item", "get", itemDetailsModel.get(0).itemId, "--otp", "--vault", itemDetailsModel.get(0).itemVaultId, "--session", currentSession]);

            }

            else varOtpSecondsLeft = secondsCountdown;

        }

    }

    Timer {

        id: sessionExpiryTimer
        interval: settings.sessionTimeLength

        onTriggered: {

            if (settings.enableTimer) lockItUp(true); // session expired so notification will publish if enabled

        }

    }

    Notification {

        id: notifySessionExpired
        isTransient: true
        urgency: Notification.Low
        expireTimeout: 750
        previewSummary: qsTr("QuayCentral Locked")

    }

    function lockItUp(expiredSession) {

        errorReadout = "";
        sessionExpiryTimer.stop();
        varOtpActive = false;
        otpDisplayedOnCover = false;
        mainOtpTimer.stop();
        signOutProcess.start("op", ["signout"]);
        signOutProcess.waitForFinished();

        if (signOutProcess.exitStatus() === 0 && errorReadout === "") {

            itemDetailsModel.clear();
            itemListModel.clear();
            vaultListModel.clear();
            pageStack.clear();
            pageStack.push(Qt.resolvedUrl("pages/SignIn.qml"), null, PageStackAction.Immediate);

            if (expiredSession && settings.sessionExpiryNotify) {

                notifySessionExpired.previewSummary = qsTr("QuayCentral Locked");
                notifySessionExpired.publish();

            }

            return qsTr("Locked");

        }

        else {

            Clipboard.text = errorReadout;
            return qsTr("Error");

        }

    }

}
