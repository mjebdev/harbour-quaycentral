import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import EncryptedStorage 1.0
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

        property bool skipVaultScreen: false
        property bool tapToCopy
        property bool enterKeyLoadsDetails
        property bool sessionExpiryNotify
        property bool ccnumHidden: true
        property bool enableTimer
        property bool includeLockMenuItem: true
        property bool loadAllItems: true
        property int sessionTimeLength: 120000
        property int sessionTimeIndex: 1
        property int whichItemsToLoadIndex: 0
        property string whichItemsToLoad: ""

    }

    property var vaultList // used to parse the JSON output before filling vaultListModel, also for active vault
    property var vaultName: ["string", "string"]
    property var vaultUUID: ["string", "string"]
    property var itemList // used to parse the JSON output before filling itemListModel
    property var itemTitle: ["string", "string"]
    property var itemTitleToUpperCase: ["string", "string"]
    property var itemUUID: ["string"]
    property var itemKind: ["string"]
    property var itemDetails // used to parse the JSON output before filling itemDetailsModel

    property int defaultVaultIndex

    property string defaultVaultUUID: ""
    property string defaultVaultTitle
    property string singleItemUsername
    property string singleItemPassword
    property string chosenCategory
    property string errorReadout
    property string standardOutput
    property string cliVersion
    property string currentSession
    property string categoriesSelected
    property string itemsVault

    property bool expiredSession
    property bool appPastLaunch
    property bool justOneVault

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

            uuid: "Loading..."; title: ""; kind: ""

        }

        function update(searchFieldText) {

            clear();

            for (var i = 0; i < itemTitle.length; i++) {

                if (searchFieldText === "" || itemTitleToUpperCase[i].indexOf(searchFieldText.toUpperCase()) >= 0) {

                    append({uuid: itemUUID[i], title: itemTitle[i], kind: itemKind[i]});

                }

            }

        }

    }

    ListModel {

        id: itemDetailsModel
        dynamicRoles: true

    }

    ListModel {

        id: sectionDetailsModel
        dynamicRoles: true

    }

    function lockItUp(expiredSession) {

        errorReadout = "";
        sessionExpiryTimer.stop();
        signOutProcess.start("op", ["signout"]);
        signOutProcess.waitForFinished();

        if (signOutProcess.exitStatus() === 0 && errorReadout === "") {

            itemDetailsModel.setProperty(0, "username", "000000000000000000000000000000000000000000000000000000000000000000000000");
            itemDetailsModel.setProperty(0, "password", "000000000000000000000000000000000000000000000000000000000000000000000000");
            itemDetailsModel.clear();
            itemListModel.clear();
            sectionDetailsModel.clear();
            vaultListModel.clear();
            itemTitle.length = 0;
            itemTitleToUpperCase.length = 0;
            // currentSession = "000000000000000000000000000000000000000000000000000000000000000000000000";
            // currentSession = "";  --unnecessary as the session key would be invalid anyway. signout was successful.
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

    Notification {

        id: notifySessionExpired
        isTransient: true
        urgency: Notification.Low
        expireTimeout: 800
        previewSummary: qsTr("QuayCentral Locked")

    }

    Process {

        id: signOutProcess
        onReadyReadStandardError: errorReadout = readAllStandardError();

    }

    Timer {

        id: sessionExpiryTimer
        interval: settings.sessionTimeLength

        onTriggered: {

            if (settings.enableTimer) lockItUp(true); // session did expire so notification will publish if enabled

        }

    }

}
