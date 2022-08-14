import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0
import "pages"

// version 0.6

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

    }

    property var vaultList // used to parse the JSON output before filling vaultListModel, also for active vault
    property var itemList // used to parse the JSON output before filling itemListModel
    property var itemDetails // used to parse the JSON output before filling itemDetailsModel
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
    property bool fetchingTotp

    ListModel {

        id: totpModel

        ListElement {

            totp: ""; totpPart1: ""; totpPart2: ""; secondsLeft: 0; primaryColor: true; active: false;

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

    ListModel {

        id: vaultListModel

        ListElement {

            name: "Loading..."; uuid: ""

        }

    }

    ListModel {

        id: itemListModel

        ListElement {

            uuid: ""; title: ""; titleUpperCase: ""; templateUuid: ""; itemVaultID: ""; itemVaultName: ""

        }

    }

    ListModel {

        id: itemSearchModel

        ListElement {

            uuid: ""; title: ""; titleUpperCase: ""; templateUuid: ""; itemVaultID: ""; itemVaultName: ""

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

            itemId: ""; itemType: ""; itemTitle: ""; itemPassword: ""; itemVaultID: ""; itemVaultName: "";

        }

    }

    Process {

        id: mainGetTotp

        onReadyReadStandardOutput: {

            var totpOutput = readAllStandardOutput();
            totpOutput = totpOutput.toString();
            totpModel.set(0, {"totp": totpOutput, "totpPart1": totpOutput.slice(0, 3), "totpPart2": totpOutput.slice(3), "primaryColor": true});
            sessionExpiryTimer.restart();
            fetchingTotp = false;

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) lockItUp(true);

            else if (errorReadout.indexOf("dial tcp") !== -1) {

                notifySessionExpired.previewSummary = "Network error when fetching One-Time Password. Please reload item when reconnected.";
                notifySessionExpired.publish();

            }

            else {

                Clipboard.text = errorReadout;
                notifySessionExpired.previewSummary = "Unknown error fetching One-Time Password (copied to clipboard).";
                notifySessionExpired.publish();

            }

        }

    }

    Process {

        id: signOutProcess
        onReadyReadStandardError: errorReadout = readAllStandardError();

    }

    Timer {

        id: mainTotpTimer
        interval: 500
        repeat: true
        triggeredOnStart: false

        onTriggered: {

            var totpCurrentTime = new Date;
            secondsCountdown = totpCurrentTime.getSeconds();
            if (secondsCountdown > 29) secondsCountdown = secondsCountdown - 30;
            secondsCountdown = (secondsCountdown - 30) * -1;

            if (secondsCountdown === 30 && fetchingTotp === false) {

                fetchingTotp = true;
                totpModel.set(0, {"secondsLeft": 30, "primaryColor": false});
                mainGetTotp.start("op", ["item", "get", itemDetailsModel.get(0).itemID, "--otp", "--vault", itemDetailsModel.get(0).itemVaultID, "--session", currentSession]);

            }

            else totpModel.set(0, {"secondsLeft": secondsCountdown});

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
        totpModel.clear(); // check to see if clear reverts active property to false, probably should
        totpModel.set(0, {"active": false});
        mainTotpTimer.stop();
        signOutProcess.start("op", ["signout"]);
        signOutProcess.waitForFinished();

        if (signOutProcess.exitStatus() === 0 && errorReadout === "") {

            itemDetailsModel.clear();
            itemListModel.clear();
            vaultListModel.clear();
            pageStack.clear();
            pageStack.push(Qt.resolvedUrl("pages/SignIn.qml"), null, PageStackAction.Immediate);
            if (expiredSession && settings.sessionExpiryNotify) notifySessionExpired.publish();
            return qsTr("Locked");

        }

        else {

            Clipboard.text = errorReadout;
            return qsTr("Error");

        }

    }

}
