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
                        if (itemsInAllVaults) getPassword.start("op", ["get", "item", itemListModel.get(0).uuid, "--session", currentSession, "--cache"]);
                        else getPassword.start("op", ["get", "item", itemListModel.get(0).uuid, "--vault", itemsVault, "--session", currentSession, "--cache"]);

                    }

                    else {

                        itemCopied = itemListModel.get(0).title;
                        allItemDetails = false;
                        if (itemsInAllVaults) getPassword.start("op", ["get", "item", itemListModel.get(0).uuid, "--fields", "password", "--session", currentSession]);
                        else getPassword.start("op", ["get", "item", itemListModel.get(0).uuid, "--vault", itemsVault, "--fields", "password", "--session", currentSession]);

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
                            if (itemsInAllVaults) getPassword.start("op", ["get", "item", uuid, "--fields", "password", "--session", currentSession]);
                            else getPassword.start("op", ["get", "item", uuid, "--fields", "password", "--vault", itemsVault, "--session", currentSession]);

                        }

                        else {

                            allItemDetails = true;
                            loadingItemBusy.running = true;
                            if (itemsInAllVaults) getPassword.start("op", ["get", "item", uuid, "--session", currentSession, "--cache"]);
                            else getPassword.start("op", ["get", "item", uuid, "--vault", itemsVault, "--session", currentSession, "--cache"]);

                        }

                    }

                    onPressAndHold: {

                        if (settings.tapToCopy || templateUuid !== "001") {

                            allItemDetails = true;
                            loadingItemBusy.running = true;
                            if (itemsInAllVaults) getPassword.start("op", ["get", "item", uuid, "--session", currentSession, "--cache"]);
                            else getPassword.start("op", ["get", "item", uuid, "--vault", itemsVault, "--session", currentSession, "--cache"]);

                        }

                        else {

                            itemCopied = title;
                            allItemDetails = false;
                            if (itemsInAllVaults) getPassword.start("op", ["get", "item", uuid, "--fields", "password", "--session", currentSession]);
                            else getPassword.start("op", ["get", "item", uuid, "--fields", "password", "--vault", itemsVault, "--session", currentSession]);

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

                    // beginning of added code from non-login section (line that added first model data entry removed)

                    sectionDetailsModel.clear();

                    if (itemDetails.overview.URLs.length > 1) { // get any additional website URLs

                        for (var y = 0; y < (itemDetails.overview.URLs.length - 1); y++) {

                            sectionDetailsModel.append({"fieldItemTitle": "website", "fieldItemValue": itemDetails.overview.URLs[y+1].u, "fieldItemKind": "url", "fieldItemName": "website"});

                        }

                    }

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

                                        sectionDetailsModel.append({"fieldItemTitle": itemDetails.sections[k].fields[l].t, "fieldItemValue": itemDetails.sections[k].fields[l].v, "fieldItemKind": itemDetails.sections[k].fields[l].k, "fieldItemName": itemDetails.details.sections[k].fields[l].n});

                                    }

                                }

                            }

                        }

                    }

                    // get notesPlain

                    if (itemDetails.details.notesPlain !== undefined && itemDetails.details.notesPlain !== "") sectionDetailsModel.append({"fieldItemTitle": "notes", "fieldItemValue": itemDetails.details.notesPlain, "fieldItemKind": "notesPlain", "fieldItemName": "notes"});

                    // -- end of added code from non-login section

                    loadingItemBusy.running = false;
                    pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                }

                else { // non-login item

                    sectionDetailsModel.clear();

                    itemDetailsModel.append({"uuid": itemDetails.uuid, "itemTitle": itemDetails.overview.title});

                    if (itemDetails.overview.URLs !== undefined && itemDetails.overview.URLs.length > 1) { // get any additional website URLs

                        for (var z = 0; z < (itemDetails.overview.URLs.length - 1); z++) {

                            sectionDetailsModel.append({"fieldItemTitle": "website", "fieldItemValue": itemDetails.overview.URLs[z+1].u, "fieldItemKind": "url", "fieldItemName": "website"});

                        }

                    }

                    if (itemDetails.details.sections !== undefined) {

                        for (var n = 0; n < itemDetails.details.sections.length; n++) {

                            if (itemDetails.details.sections[n].fields !== undefined) {

                                for (var p = 0; p < itemDetails.details.sections[n].fields.length; p++) {

                                    if (itemDetails.details.sections[n].fields[p].v !== undefined && itemDetails.details.sections[n].fields[p].v !== "" && itemDetails.details.sections[n].fields[p].t !== undefined && itemDetails.details.sections[n].fields[p].k !== undefined) {

                                        sectionDetailsModel.append({"fieldItemTitle": itemDetails.details.sections[n].fields[p].t, "fieldItemValue": itemDetails.details.sections[n].fields[p].v, "fieldItemKind": itemDetails.details.sections[n].fields[p].k, "fieldItemName": itemDetails.details.sections[n].fields[p].n});

                                    }

                                }

                            }

                        }

                    }

                    if (itemDetails.sections !== undefined) {

                        for (var q = 0; q < itemDetails.sections.length; q++) {

                            if (itemDetails.sections[q].fields !== undefined) {

                                for (var r = 0; r < itemDetails.sections[q].fields.length; r++) {

                                    if (itemDetails.sections[q].fields[r].v !== undefined && itemDetails.sections[q].fields[r].v !== "" && itemDetails.sections[q].fields[r].t !== undefined && itemDetails.sections[q].fields[r].k !== undefined) {

                                        sectionDetailsModel.append({"fieldItemTitle": itemDetails.sections[q].fields[r].t, "fieldItemValue": itemDetails.sections[q].fields[r].v, "fieldItemKind": itemDetails.sections[q].fields[r].k, "fieldItemName": itemDetails.details.sections[q].fields[r].n});

                                    }

                                }

                            }

                        }

                    }

                    if (itemDetails.details.notesPlain !== undefined && itemDetails.details.notesPlain !== "") sectionDetailsModel.append({"fieldItemTitle": "notes", "fieldItemValue": itemDetails.details.notesPlain, "fieldItemKind": "notesPlain", "fieldItemName": "notes"});

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
