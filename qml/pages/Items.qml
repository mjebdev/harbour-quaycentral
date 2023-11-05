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
    property bool localListingFin: appWindow.itemListingFin

    onStatusChanged: {

        if (status === PageStatus.Active) {

            mainOtpTimer.stop();
            otpModel.set(0, {"active": false});
            otpDisplayedOnCover = false;
            itemsPageObject = pageStack.currentPage;

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

                otpModel.set(0, {"active": false});
                searchFieldMargin = this.textLeftMargin; // to get around errors with alias and direct identification of searchField not functioning as expected.
                if (searchField.text === "") searchField.forceActiveFocus();

            }

            onTextChanged: {

                itemSearchModel.update(text);

            }

            EnterKey.onClicked: {

                if (itemSearchModel.count > 0 && text.length > 0) {

                    if (settings.enterKeyLoadsDetails || itemSearchModel.get(0).templateUuid !== "LOGIN") {

                        itemDetailsModel.set(0, {"itemId": itemSearchModel.get(0).uuid, "itemTitle": itemSearchModel.get(0).title, "itemType": itemSearchModel.get(0).templateUuid, "itemVaultId": itemSearchModel.get(0).itemVaultId, "itemVaultName": itemSearchModel.get(0).itemVaultName});
                        pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                    }

                    else {

                        itemCopied = itemSearchModel.get(0).title;
                        getPassword.start("op", ["item", "get", itemSearchModel.get(0).uuid, "--vault", itemSearchModel.get(0).itemVaultId, "--fields", "label=password", "--session", currentSession]);

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
                    visible: templateUuid !== "DOCUMENT"

                    Icon {

                        id: itemIcon
                        source: iconUrl
                        visible: iconEmoji === ""

                        anchors {

                            left: parent.left
                            leftMargin: searchFieldMargin - this.width - Theme.paddingMedium
                            verticalCenter: parent.verticalCenter

                        }

                    }
                    
                    Label {
                        
                        id: itemEmojiIcon
                        padding: 0
                        visible: iconEmoji !== ""
                        text: iconEmoji
                        font.pixelSize: Theme.fontSizeExtraLarge
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                        width: Theme.iconSizeMedium
                        horizontalAlignment: "AlignHCenter"

                        anchors {
                            
                            left: parent.left
                            leftMargin: searchFieldMargin - this.width - Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                            
                        }

                    }

                    Label {

                        anchors {

                            left: itemIcon.visible ? itemIcon.right : itemEmojiIcon.right
                            leftMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter

                        }

                        text: title
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                    }

                    onClicked: {

                        if (settings.tapToCopy && templateUuid === "LOGIN") {

                            itemCopied = title;
                            getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultId, "--session", currentSession]);

                        }

                        else {

                            itemDetailsModel.set(0, {"itemId": uuid, "itemTitle": title, "itemType": templateUuid, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName});
                            pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                        }

                    }

                    onPressAndHold: {

                        if (settings.tapToCopy || templateUuid !== "LOGIN") {

                            itemDetailsModel.set(0, {"itemId": uuid, "itemTitle": title, "itemType": templateUuid, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName});
                            pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                        }

                        else {

                            itemCopied = title;
                            getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultId, "--session", currentSession]);

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
            var prelimOutput = readAllStandardOutput();
            prelimOutput = " " + prelimOutput + " "; // need to avoid error: TypeError: Property 'trim' of object [password string w/ new line at end] is not a function.
            prelimOutput = prelimOutput.trim();
            Clipboard.text = prelimOutput;
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
                itemsPageNotification.publish();
                Clipboard.text = errorReadout;
                lockItUp(false);

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
        running: !localListingFin

    }

}
