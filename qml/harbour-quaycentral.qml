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
        property bool skipVaultScreen: false
        property bool tapToCopy
        property bool enterKeyLoadsDetails
        property bool sessionExpiryNotify
        property string defaultVaultUUID: ""
        property int sessionTimeLength: 1790000
        property int sessionTimeIndex: 4

    }

    property var itemList
    property var itemDetails
    property var itemTitle: ["string", "string"]
    property var itemTitleToUpperCase: ["string", "string"]
    property var itemUUID: ["string", "string"]
    property var itemCategory
    property var itemWebsite
    property var vaultList
    property var vaultName: ["string", "string"]
    property var vaultUUID: ["string", "string"]
    property string itemToLoad
    property string singleItemUsername
    property string singleItemPassword
    property string errorReadout
    property string cliVersion
    property string currentSession
    property bool expiredSession
    property bool appPastLaunch

    ListModel {

        id: vaultListModel

        ListElement {

            name: "Loading..."; uuid: ""

        }

    }

    ListModel {

        id: itemDetailsModel

        ListElement {

            uuid: ""; itemTitle: ""; username: ""; password: ""; website: "";

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
            itemTitle.length = 0;
            itemTitleToUpperCase.length = 0;
            currentSession = "000000000000000000000000000000000000000000000000000000000000000000000000";
            currentSession = "";
            pageStack.clear();
            pageStack.push(Qt.resolvedUrl("pages/SignIn.qml"), null, PageStackAction.Immediate);

            if (expiredSession && settings.sessionExpiryNotify) notifySessionExpired.publish();

            return "Locked";

        }

        else {

            Clipboard.text = errorReadout;
            return "Error";

        }

    }

    Notification {

        id: notifySessionExpired
        isTransient: true
        urgency: Notification.Low
        previewSummary: "QuayCentral session has expired."

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
