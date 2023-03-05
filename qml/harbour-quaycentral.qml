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

    }

    property var itemsPageObject
    property int secondsCountdown
    property string chosenCategory
    property string errorReadout
    property string standardOutput
    property string cliVersion
    property string currentSession
    property string categoriesSelected
    property bool expiredSession
    property bool appPastLaunch
    property bool justOneVault
    property bool fetchingOtp
    property bool otpDisplayedOnCover
    property bool anyFavItems

    ListModel {

        id: otpModel

        ListElement {

            otp: ""; otpPart1: ""; otpPart2: ""; secondsLeft: 0; primaryColor: true; active: false;

        }

    }

    ListModel {

        id: largeTypeModel

        ListElement {

            character: ""

        }

    }

    ListModel {

        id: categoryListModel

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
        ListElement {categoryName: "Wireless Router"; categoryDisplayName: qsTr("Wireless Routers")}

    }

    ListModel {

        id: vaultListModel

        ListElement {

            name: "Loading..."; uuid: ""

        }

    }

    ListModel {

        id: itemListModel

        ListElement {

            uuid: ""; title: ""; titleUpperCase: ""; templateUuid: ""; itemVaultId: ""; itemVaultName: ""

        }

    }

    ListModel {

        id: itemSearchModel

        ListElement {

            uuid: ""; title: ""; titleUpperCase: ""; templateUuid: ""; itemVaultId: ""; itemVaultName: ""

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

            itemId: ""; itemType: ""; itemTitle: ""; itemPassword: ""; itemVaultId: ""; itemVaultName: "";

        }

    }

    ListModel {

        id: favItemsModel

        ListElement {

            itemId: ""; itemType: ""; itemTitle: ""; itemVaultId: ""; itemVaultName: "";


        }

    }

    Process {

        id: mainGetOtp

        onReadyReadStandardOutput: {

            var otpOutput = readAllStandardOutput();
            otpOutput = otpOutput.toString();
            otpModel.set(0, {"otp": otpOutput, "otpPart1": otpOutput.slice(0, 3), "otpPart2": otpOutput.slice(3), "primaryColor": true});
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
                otpModel.set(0, {"secondsLeft": 30, "primaryColor": false});
                mainGetOtp.start("op", ["item", "get", itemDetailsModel.get(0).itemId, "--otp", "--vault", itemDetailsModel.get(0).itemVaultId, "--session", currentSession]);

            }

            else otpModel.set(0, {"secondsLeft": secondsCountdown});

        }

    }

    Timer {

        id: sessionExpiryTimer
        interval: settings.sessionTimeLength

        onTriggered: {

            if (settings.enableTimer) lockItUp(true); // session did expire so notification will publish if enabled

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
        otpModel.clear(); // check to see if clear reverts active property to false, probably should
        otpModel.set(0, {"active": false});
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
