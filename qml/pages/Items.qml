import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string itemCopied
    property int searchFieldMargin

    onStatusChanged: {

        if (status === PageStatus.Active) {

            mainTotpTimer.stop();
            totpModel.set(0, {"active": false});

        }

    }

    SilicaListView {

        id: itemListView
        currentIndex: -1
        model: itemSearchModel
        anchors.fill: parent

        PullDownMenu {

            visible: settings.includeLockMenuItem

            MenuItem {

                text: qsTr("Lock")
                onClicked: lockItUp(false);

            }

        }

        header: SearchField {

            id: searchField
            width: parent.width
            placeholderText: qsTr("Search items")

            Component.onCompleted: {

                totpModel.set(0, {"active": false});
                searchFieldMargin = this.textLeftMargin; // to get around errors with alias and direct identification of searchField not functioning as expected.
                if (searchField.text === "") searchField.forceActiveFocus();

            }

            onTextChanged: {

                itemSearchModel.update(text);

            }

            EnterKey.onClicked: {

                // needs to be at least one result to work with and not a full list / empty field.
                if (itemSearchModel.count > 0 && text.length > 0) {

                    if (settings.enterKeyLoadsDetails || itemSearchModel.get(0).templateUuid !== "LOGIN") {

                        itemDetailsModel.set(0, {"itemID": itemSearchModel.get(0).uuid, "itemTitle": itemSearchModel.get(0).title, "itemType": itemSearchModel.get(0).templateUuid, "itemVaultID": itemSearchModel.get(0).itemVaultID, "itemVaultName": itemSearchModel.get(0).itemVaultName});
                        pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                    }

                    else {

                        itemCopied = itemSearchModel.get(0).title;
                        //allItemDetails = false;
                        getPassword.start("op", ["item", "get", itemSearchModel.get(0).uuid, "--vault", itemSearchModel.get(0).itemVaultID, "--fields", "label=password", "--session", currentSession]);

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

                        if (settings.tapToCopy && templateUuid === "LOGIN") {

                            itemCopied = title;
                            //allItemDetails = false;
                            getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultID, "--session", currentSession]);

                        }

                        else {

                            itemDetailsModel.set(0, {"itemID": uuid, "itemTitle": title, "itemType": templateUuid, "itemVaultID": itemVaultID, "itemVaultName": itemVaultName});
                            pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                        }

                    }

                    onPressAndHold: {

                        if (settings.tapToCopy || templateUuid !== "LOGIN") {

                            itemDetailsModel.set(0, {"itemID": uuid, "itemTitle": title, "itemType": templateUuid, "itemVaultID": itemVaultID, "itemVaultName": itemVaultName});
                            pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                        }

                        else {

                            itemCopied = title;
                            //allItemDetails = false;
                            getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultID, "--session", currentSession]);

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
            //itemDetailsModel.clear();  //  not needed?
            //var prelimOutput = readAllStandardOutput();
            //Clipboard.text = prelimOutput;
            Clipboard.text = readAllStandardOutput();
            itemsPageNotification.previewSummary = qsTr("%1 password copied.").arg(itemCopied);
            itemsPageNotification.publish();

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            sessionExpiryTimer.stop();
            loadingItemBusy.running = false;

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) lockItUp(true);

            else {

                itemsPageNotification.previewSummary = "Unknown Error (copied to clipboard). Please sign back in.";
                Clipboard.text = errorReadout;

                itemsPageNotification.publish();
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

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
