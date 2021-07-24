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

            visible: settings.includeLockMenuItem

            MenuItem {

                text: qsTr("Lock")
                onClicked: lockItUp(false)

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

                    if (settings.enterKeyLoadsDetails || itemListModel.get(0).templateUuid !== "001") {

                        loadingItemBusy.running = true;
                        allItemDetails = true;
                        getPassword.start("op", ["get", "item", itemListModel.get(0).uuid, "--vault", itemsVault, "--session", currentSession, "--cache"]);

                    }

                    else {

                        itemCopied = itemListModel.get(0).title;
                        allItemDetails = false;
                        getPassword.start("op", ["get", "item", itemListModel.get(0).uuid, "--vault", itemsVault, "--fields", "password", "--session", currentSession]);

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

                        if (settings.tapToCopy && templateUuid === "001") {

                            itemCopied = title;
                            allItemDetails = false;
                            getPassword.start("op", ["get", "item", uuid, "--fields", "password", "--vault", itemsVault, "--session", currentSession]);

                        }

                        else {

                            allItemDetails = true;
                            loadingItemBusy.running = true;
                            getPassword.start("op", ["get", "item", uuid, "--vault", itemsVault, "--session", currentSession, "--cache"]);

                        }

                    }

                    onPressAndHold: {

                        if (settings.tapToCopy || templateUuid !== "001") {

                            allItemDetails = true;
                            loadingItemBusy.running = true;
                            getPassword.start("op", ["get", "item", uuid, "--vault", itemsVault, "--session", currentSession, "--cache"]);

                        }

                        else {

                            itemCopied = title;
                            allItemDetails = false;
                            getPassword.start("op", ["get", "item", uuid, "--fields", "password", "--vault", itemsVault, "--session", currentSession]);

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
            itemDetailsModel.clear();
            var prelimOutput = readAllStandardOutput();

            if (allItemDetails) { // load item details and move to itemDetails page

                itemDetails = JSON.parse(prelimOutput);
                singleItemUsername = ""; // incase none is returned from CLI
                singleItemPassword = "";

                if (itemDetails.templateUuid === "001") { // login item

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

                else { // non-login item

                    sectionDetailsModel.clear();

                    itemDetailsModel.append({"uuid": itemDetails.uuid, "itemTitle": itemDetails.overview.title});

                    if (itemDetails.details.sections !== undefined) {

                        for (var m = 0; m < itemDetails.details.sections.length; m++) {

                            if (itemDetails.details.sections[m].fields !== undefined) {

                                for (var j = 0; j < itemDetails.details.sections[m].fields.length; j++) {

                                    if (itemDetails.details.sections[m].fields[j].v !== undefined && itemDetails.details.sections[m].fields[j].v !== "" && itemDetails.details.sections[m].fields[j].t !== undefined && itemDetails.details.sections[m].fields[j].k !== undefined) {

                                        sectionDetailsModel.append({"fieldItemTitle": itemDetails.details.sections[m].fields[j].t, "fieldItemValue": itemDetails.details.sections[m].fields[j].v, "fieldItemKind": itemDetails.details.sections[m].fields[j].k, "fieldItemName": itemDetails.details.sections[m].fields[j].n});

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

            }

            else { // Just the password to be copied to clipboard.

                Clipboard.text = prelimOutput;
                itemsPageNotification.previewSummary = qsTr("%1 Copied").arg(itemCopied);
                itemsPageNotification.publish();

            }

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            sessionExpiryTimer.stop();
            loadingItemBusy.running = false;

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) itemsPageNotification.previewSummary = "Session Expired";

            else {

                itemsPageNotification.previewSummary = "Unknown Error (copied to clipboard). Please sign back in.";
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
