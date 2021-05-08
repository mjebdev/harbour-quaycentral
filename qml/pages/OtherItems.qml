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

            // sessionExpiryTimer.restart();

            // code to handle other kinds of items

            itemDetailsModel.clear();
            sectionDetailsModel.clear();
            var prelimOutput = readAllStandardOutput();
            itemDetails = JSON.parse(prelimOutput);

            itemDetailsModel.append({"uuid": itemDetails.uuid, "itemTitle": itemDetails.overview.title});

            if (itemDetails.details.sections !== undefined) {

                for (var i = 0; i < itemDetails.details.sections.length; i++) {

                    //itemDetailsModel.append({"sections": {"sectionTitle": itemDetails.details.sections[i].title}});

                    //if (itemDetails.details.sections[i].title !== "") Clipboard.text = itemDetails.details.sections[i].title.toString();

                    if (itemDetails.details.sections[i].fields !== undefined) {

                        for (var j = 0; j < itemDetails.details.sections[i].fields.length; j++) {

                            if (itemDetails.details.sections[i].fields[j].v !== undefined && itemDetails.details.sections[i].fields[j].v !== "" && itemDetails.details.sections[i].fields[j].t !== undefined && itemDetails.details.sections[i].fields[j].k !== undefined) {

                                //if (itemDetails.details.sections[i].fields[j].k !== "concealed" || itemDetails.details.sections[i].fields[j].k !== "URL" || itemDetails.details.sections[i].fields[j].k !== "notesPlain") itemDetails.details.sections[i].fields[j].k = "textfield";

                                //if (itemDetails.details.sections[i].fields[j].k !== ("concealed" || "URL" || "notesPlain")) itemDetails.details.sections[i].fields[j].k = "textfield";

                                // sectionDetailsModel.append({"fieldItemTitle": itemDetails.details.sections[i].fields[j].t, "fieldItemValue": itemDetails.details.sections[i].fields[j].v, "fieldItemKind": itemDetails.details.sections[i].fields[j].k});

                                sectionDetailsModel.append({"fieldItemTitle": itemDetails.details.sections[i].fields[j].t, "fieldItemValue": itemDetails.details.sections[i].fields[j].v, "fieldItemKind": itemDetails.details.sections[i].fields[j].k, "fieldItemName": itemDetails.details.sections[i].fields[j].n});

                            }

                        }

                    }

                    else {

                        // no fields in this section - remove section header?

                    }

                }

            }

            if (itemDetails.sections !== undefined) {

                for (var k = 0; k < itemDetails.sections.length; k++) {

                    if (itemDetails.sections[k].fields !== undefined) {

                        for (var l = 0; l < itemDetails.sections[k].fields.length; l++) {

                            if (itemDetails.sections[k].fields[l].v !== undefined && itemDetails.sections[k].fields[l].v !== "" && itemDetails.sections[k].fields[l].t !== undefined && itemDetails.sections[k].fields[l].k !== undefined) {

                                //if (itemDetails.sections[k].fields[l].k !== "concealed" || itemDetails.sections[k].fields[l].k !== "URL" || itemDetails.sections[k].fields[l].k !== "notesPlain") itemDetails.sections[k].fields[l].k = "textfield";
                                // if (itemDetails.sections[k].fields[l].k !== ("concealed" || "URL" || "notesPlain")) itemDetails.sections[k].fields[l].k = "textfield";

                                // sectionDetailsModel.append({"fieldItemTitle": itemDetails.sections[k].fields[l].t, "fieldItemValue": itemDetails.sections[k].fields[l].v, "fieldItemKind": itemDetails.sections[k].fields[l].k});

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

            sessionExpiryTimer.restart();
            passwordCopied.previewSummary = qsTr("Error - Unable to load item details.");
            passwordCopied.body = readAllStandardError();
            passwordCopied.urgency = Notification.Medium;
            passwordCopied.publish();
            passwordCopied.urgency = Notification.Low; // back to normal setting

        }

    }

    Notification {

        id: passwordCopied
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
