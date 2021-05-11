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

        // Below option in Settings to be enabled when there is a Sailfish-Secrets implementation
        // in the app, with which the default vault UUID can be stored securely.
        // property string defaultVaultUUID: ""
        property bool skipVaultScreen: false
        property bool tapToCopy
        property bool enterKeyLoadsDetails
        property bool sessionExpiryNotify
        property bool ccnumHidden: true
        property int sessionTimeLength: 900000
        property int sessionTimeIndex: 4

    }

    property var vaultList // used to parse the JSON output before filling vaultListModel, also for active vault
    property var vaultName: ["string", "string"]
    property var vaultUUID: ["string", "string"]

    property var itemList // used to parse the JSON output before filling itemListModel
    property var itemTitle: ["string", "string"]
    property var itemTitleToUpperCase: ["string", "string"]
    property var itemUUID: ["string", "string"]

    property var itemDetails // used to parse the JSON output before filling itemDetailsModel
    property string singleItemUsername
    property string singleItemPassword
    property string chosenCategory

    property string errorReadout
    property string cliVersion
    property string currentSession
    property bool expiredSession
    property bool appPastLaunch
    property bool justOneVault

    ListModel {

        id: vaultListModel

        ListElement {

            name: "Loading..."; uuid: ""

        }

    }

    ListModel {

        id: itemListModel

        ListElement {

            uuid: "Loading..."; title: ""

        }

        function update(searchFieldText) {

            clear();

            for (var i = 0; i < itemTitle.length; i++) {

                if (searchFieldText === "" || itemTitleToUpperCase[i].indexOf(searchFieldText.toUpperCase()) >= 0) {

                    append({uuid: itemUUID[i], title: itemTitle[i]});

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

            lockItUp(true); // session did expire so notification will publish

        }

    }

}
