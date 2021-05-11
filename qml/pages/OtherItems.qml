import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property int searchFieldMargin

    SilicaListView {

        id: itemListView
        currentIndex: -1
        model: itemListModel
        anchors.fill: parent

        PullDownMenu {

            PullDownMenu {

                MenuItem {

                    text: qsTr("Lock");
                    onClicked: lockItUp(false);

                }

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

                    loadingItemBusy.running = true;
                    getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], itemListModel.get(0).uuid, "--session", currentSession]);
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

                        loadingItemBusy.running = true;
                        getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], uuid, "--session", currentSession]);

                    }

                    onPressAndHold: {

                        loadingItemBusy.running = true;
                        getPassword.start("op", ["get", "item", "--vault", vaultUUID[0], uuid, "--session", currentSession]);

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
            itemDetailsModel.clear();
            sectionDetailsModel.clear();
            var prelimOutput = readAllStandardOutput();
            itemDetails = JSON.parse(prelimOutput);

            itemDetailsModel.append({"uuid": itemDetails.uuid, "itemTitle": itemDetails.overview.title});

            if (itemDetails.details.sections !== undefined) {

                for (var i = 0; i < itemDetails.details.sections.length; i++) {

                    if (itemDetails.details.sections[i].fields !== undefined) {

                        for (var j = 0; j < itemDetails.details.sections[i].fields.length; j++) {

                            if (itemDetails.details.sections[i].fields[j].v !== undefined && itemDetails.details.sections[i].fields[j].v !== "" && itemDetails.details.sections[i].fields[j].t !== undefined && itemDetails.details.sections[i].fields[j].k !== undefined) {

                                sectionDetailsModel.append({"fieldItemTitle": itemDetails.details.sections[i].fields[j].t, "fieldItemValue": itemDetails.details.sections[i].fields[j].v, "fieldItemKind": itemDetails.details.sections[i].fields[j].k, "fieldItemName": itemDetails.details.sections[i].fields[j].n});

                            }

                        }

                    }

                }

            }

            if (itemDetails.sections !== undefined) {

                for (var k = 0; k < itemDetails.sections.length; k++) {

                    if (itemDetails.sections[k].fields !== undefined) {

                        for (var l = 0; l < itemDetails.sections[k].fields.length; l++) {

                            if (itemDetails.sections[k].fields[l].v !== undefined && itemDetails.sections[k].fields[l].v !== "" && itemDetails.sections[k].fields[l].t !== undefined && itemDetails.sections[k].fields[l].k !== undefined) {

                                sectionDetailsModel.append({"fieldItemTitle": itemDetails.sections[k].fields[l].t, "fieldItemValue": itemDetails.sections[k].fields[l].v, "fieldItemKind": itemDetails.sections[k].fields[l].k, "fieldItemName": itemDetails.details.sections[i].fields[j].n});

                            }

                        }

                    }

                }

            }

            loadingItemBusy.running = false;
            pageStack.push(Qt.resolvedUrl("OtherItemDetails.qml"));

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
