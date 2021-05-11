import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string itemCopied
    property bool allItemDetails
    property int searchFieldMargin

    SilicaListView {

        id: itemListView
        currentIndex: -1
        model: itemListModel
        anchors.fill: parent

        PullDownMenu {

            MenuItem {

                text: qsTr("Lock");
                onClicked: lockItUp(false);

            }

        }

        header: SearchField {

            id: searchField
            width: parent.width
            placeholderText: qsTr("Search items")

            Component.onCompleted: {

                searchFieldMargin = this.textLeftMargin; // to get around errors with alias and direct identification of searchField not functioning as expected.
                if (searchField.text === "") searchField.forceActiveFocus();

            }

            onTextChanged: {

                itemListModel.update(text);

            }

            EnterKey.onClicked: {

                // needs to be at least one result to work with and not a full list / empty field.
                if (itemListModel.count > 0 && text.length > 0) {

                    if (settings.enterKeyLoadsDetails) {

                        loadingItemBusy.running = true;
                        allItemDetails = true;
                        getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], itemListModel.get(0).uuid, "--session", currentSession]);

                    }

                    else {

                        itemCopied = itemListModel.get(0).title;
                        allItemDetails = false;
                        getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], itemListModel.get(0).uuid, "--fields", "password", "--session", currentSession]);

                    }

                    searchField.focus = false;
                    searchField.text = "";

                }

                else if (text === "") searchField.focus = false;

            }

        }

        delegate: Column {

            id: delegateColumn
            width: parent.width
            height: itemRow.height

            Row {

                width: parent.width
                id: itemRow
                spacing: Theme.paddingMedium

                BackgroundItem {

                    id: delegate

                    Label {

                        anchors {

                            left: parent.left
                            leftMargin: searchFieldMargin
                            verticalCenter: parent.verticalCenter

                        }

                        text: title
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                    }

                    onClicked: {

                        if (settings.tapToCopy) {

                            itemCopied = title;
                            allItemDetails = false;
                            getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], uuid, "--fields", "password", "--session", currentSession]);

                        }

                        else {

                            allItemDetails = true;
                            loadingItemBusy.running = true;
                            getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], uuid, "--session", currentSession]);

                        }

                    }

                    onPressAndHold: {

                        if (settings.tapToCopy) {

                            allItemDetails = true;
                            loadingItemBusy.running = true;
                            getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], uuid, "--session", currentSession]);

                        }

                        else {

                            itemCopied = title;
                            allItemDetails = false;
                            getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], uuid, "--fields", "password", "--session", currentSession]);

                        }

                    }

                }

            }

        }

        VerticalScrollDecorator { }

    }

    Process {

        id: getPassword

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();

            if (allItemDetails) { // load item details and move to itemDetails page

                singleItemUsername = ""; // incase none is returned from CLI
                singleItemPassword = "";
                itemDetailsModel.clear();
                var prelimOutput = readAllStandardOutput();
                itemDetails = JSON.parse(prelimOutput);

                for (var i = 0; i < itemDetails.details.fields.length; i++) {

                    switch (itemDetails.details.fields[i].designation) {

                    case "username":

                        singleItemUsername = itemDetails.details.fields[i].value;
                        break;

                    case "password":

                        singleItemPassword = itemDetails.details.fields[i].value;

                    }

                }

                itemDetailsModel.append({"uuid": itemDetails.uuid, "itemTitle": itemDetails.overview.title, "username": singleItemUsername, "password": singleItemPassword, "website": itemDetails.overview.url});
                singleItemPassword = "0000000000000000000000000000000000000000000000000000000000000000";
                singleItemPassword = "";
                singleItemUsername = "0000000000000000000000000000000000000000000000000000000000000000";
                singleItemUsername = "";
                loadingItemBusy.running = false;
                pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

            }

            else { // Just the password to be copied to clipboard.

                Clipboard.text = readAllStandardOutput();
                itemsPageNotification.previewSummary = qsTr("%1 Copied").arg(itemCopied);
                itemsPageNotification.publish();

            }

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            sessionExpiryTimer.stop();
            loadingItemBusy.running = false;

            if (errorReadout.indexOf("session expired") !== -1) itemsPageNotification.previewSummary = "Session Expired";
            else if (errorReadout.indexOf("not currently signed in") !== -1) itemsPageNotification.previewSummary = "Not Currently Signed In";

            else {

                itemsPageNotification.previewSummary = "Unknown Error - Please check network and try signing in again.";
                Clipboard.text = errorReadout;

            }

            itemsPageNotification.publish();
            pageStack.clear();
            pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            /*  this code allowed for the user to continue despite error if it wasn't sign-in related; changing
                for sake of extra security, error of any kind will now kick user out and force re-signing in.
            if (allItemDetails) {

                itemsPageNotification.previewSummary = qsTr("Error - Unable to load item details.");
                itemsPageNotification.body = readAllStandardError();
                itemsPageNotification.urgency = Notification.Medium;
                itemsPageNotification.publish();
                itemsPageNotification.urgency = Notification.Low; // back to normal setting

            }

            else {

                itemsPageNotification.previewSummary = qsTr("Error - Password not copied.");
                itemsPageNotification.body = readAllStandardError();
                itemsPageNotification.urgency = Notification.Medium;
                itemsPageNotification.publish();
                itemsPageNotification.urgency = Notification.Low; // back to normal setting

            }
            */

        }

    }

    Notification {

        id: itemsPageNotification
        appName: "QuayCentral"
        urgency: Notification.Low
        isTransient: true
        expireTimeout: 1500

    }

    BusyIndicator {

        id: loadingItemBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: false

    }

}
