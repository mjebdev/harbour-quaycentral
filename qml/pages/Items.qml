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
    property bool allItemDetails

    onStatusChanged: {

        if (status === PageStatus.Active) {

            itemDetailsModel.clear();
            mainOtpTimer.stop();
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

                otpDisplayedOnCover = false;
                searchFieldMargin = this.textLeftMargin;

                if (searchFieldMargin > Theme.paddingLarge) { // OS version 4.5 or earlier - rendered differently.

                    if (settings.showItemIconsInList) searchFieldMargin = searchFieldMargin - Theme.iconSizeMedium - Theme.paddingMedium;

                }

                else if (!settings.showItemIconsInList) searchFieldMargin = searchFieldMargin + Theme.iconSizeMedium + Theme.paddingMedium;
                if (searchField.text === "") searchField.forceActiveFocus();

            }

            onTextChanged: {

                itemSearchModel.update(text);

            }

            EnterKey.onClicked: {

                loadingItemBusy.running = true;

                if (itemSearchModel.count > 0 && text.length > 0) {

                    if (settings.enterKeyLoadsDetails || itemSearchModel.get(0).templateUuid !== "LOGIN") {

                        allItemDetails = true;
                        itemDetailsModel.clear();
                        itemDetailsModel.set(0, {"itemId": uuid, "itemTitle": title, "itemType": templateUuid, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName, "itemFields": [{"fieldId": "", "fieldType": "", "fieldLabel": "", "fieldValue": "", "fieldOtp": ""}]});
                        getPassword.start("op", ["item", "get", uuid, "--vault", itemVaultId, "--format", "json", "--session", currentSession]);

                    }

                    else {

                        allItemDetails = false;
                        itemCopied = title;
                        getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultId, "--session", currentSession]);

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
                        visible: iconEmoji === "" && settings.showItemIconsInList

                        anchors {

                            left: parent.left
                            leftMargin: searchFieldMargin
                            verticalCenter: parent.verticalCenter

                        }

                    }
                    
                    Label {
                        
                        id: itemEmojiIcon
                        padding: 0
                        visible: iconEmoji !== "" && settings.showItemIconsInList
                        text: iconEmoji
                        font.pixelSize: Theme.fontSizeExtraLarge
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                        width: Theme.iconSizeMedium
                        horizontalAlignment: "AlignHCenter"

                        anchors {
                            
                            left: parent.left
                            leftMargin: searchFieldMargin
                            verticalCenter: parent.verticalCenter
                            
                        }

                    }

                    Label {

                        anchors {

                            left: settings.showItemIconsInList ? itemIcon.visible ? itemIcon.right : itemEmojiIcon.right : parent.left
                            leftMargin: settings.showItemIconsInList ? Theme.paddingMedium : searchFieldMargin
                            verticalCenter: parent.verticalCenter

                        }

                        width: page.width - this.x - (Theme.paddingMedium * 2)
                        truncationMode: TruncationMode.Fade
                        text: title
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                    }

                    onClicked: {

                        loadingItemBusy.running = true;

                        if (settings.tapToCopy && templateUuid === "LOGIN") {

                            allItemDetails = false;
                            itemCopied = title;
                            getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultId, "--session", currentSession]);

                        }

                        else {

                            allItemDetails = true;
                            itemDetailsModel.clear();
                            itemDetailsModel.set(0, {"itemId": uuid, "itemTitle": title, "itemType": templateUuid, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName, "itemFields": [{"fieldId": "", "fieldType": "", "fieldLabel": "", "fieldValue": "", "fieldOtp": ""}]});
                            getPassword.start("op", ["item", "get", uuid, "--vault", itemVaultId, "--format", "json", "--session", currentSession]);

                        }

                    }

                    onPressAndHold: {

                        loadingItemBusy.running = true;

                        if (settings.tapToCopy || templateUuid !== "LOGIN") {

                            allItemDetails = true;
                            itemDetailsModel.clear();
                            itemDetailsModel.set(0, {"itemId": uuid, "itemTitle": title, "itemType": templateUuid, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName, "itemFields": [{"fieldId": "", "fieldType": "", "fieldLabel": "", "fieldValue": "", "fieldOtp": ""}]});
                            getPassword.start("op", ["item", "get", uuid, "--vault", itemVaultId, "--format", "json", "--session", currentSession]);

                        }

                        else {

                            allItemDetails = false;
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

            if (allItemDetails) {

                var itemDetails = JSON.parse(prelimOutput);
                itemDetailsModel.get(0).itemFields.clear();

                for (var i = 0; i < itemDetails.fields.length; i++) {

                    if (itemDetails.fields[i].id !== "" && itemDetails.fields[i].value !== undefined) itemDetailsModel.get(0).itemFields.append({"fieldId": itemDetails.fields[i].id, "fieldType": itemDetails.fields[i].type, "fieldLabel": itemDetails.fields[i].label, "fieldValue": itemDetails.fields[i].value, "fieldOtp": itemDetails.fields[i].totp !== undefined ? itemDetails.fields[i].totp : ""});

                }

                if (itemDetails.urls !== undefined) {

                    for (var j = 0; j < itemDetails.urls.length; j++) itemDetailsModel.get(0).itemFields.append({"fieldId": "URL", "fieldType": "URL", "fieldLabel": itemDetails.urls[j].label, "fieldValue": itemDetails.urls[j].href, "fieldOtp": ""});

                }

                pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

            }

            else {

                Clipboard.text = prelimOutput;
                itemsPageNotification.previewSummary = qsTr("%1 password copied.").arg(itemCopied);
                itemsPageNotification.publish();

            }

            loadingItemBusy.running = false;

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
        running: false

    }

}
