import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string itemCopied
    property string passwordStr
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
                searchField.forceActiveFocus();

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
                        itemDetailsModel.set(0, {"itemId": itemSearchModel.get(0).uuid, "itemTitle": itemSearchModel.get(0).title, "itemType": itemSearchModel.get(0).templateUuid, "itemVaultId": itemSearchModel.get(0).itemVaultId, "itemVaultName": itemSearchModel.get(0).itemVaultName, "itemFields": [{"fieldId": "", "fieldType": "", "fieldLabel": "", "fieldValue": "", "fieldOtp": ""}]});
                        getPassword.start("op", ["item", "get", itemSearchModel.get(0).uuid, "--vault", itemSearchModel.get(0).itemVaultId, "--format", "json", "--session", currentSession]);

                    }

                    else {

                        allItemDetails = false;
                        itemCopied = itemSearchModel.get(0).title;
                        getPassword.start("op", ["item", "get", itemSearchModel.get(0).uuid, "--fields", "label=password", "--vault", itemSearchModel.get(0).itemVaultId, "--reveal", "--session", currentSession]);

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
                //x: Theme.horizontalPageMargin

                BackgroundItem {

                    id: delegate
                    visible: templateUuid !== "DOCUMENT"

                    Icon {

                        id: itemIcon
                        source: iconUrl
                        visible: iconEmoji === "" && settings.showItemIconsInList
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        height: Theme.iconSizeMedium
                        width: height

                    }
                    
                    Label {
                        
                        id: itemEmojiIcon
                        visible: iconEmoji !== "" && settings.showItemIconsInList
                        text: iconEmoji
                        font.pixelSize: Theme.fontSizeExtraLarge
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                        width: Theme.iconSizeMedium
                        horizontalAlignment: "AlignHCenter"
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter

                    }

                    Label {

                        anchors.left: settings.showItemIconsInList ? itemIcon.visible ? itemIcon.right : itemEmojiIcon.right : parent.left
                        anchors.leftMargin: settings.showItemIconsInList ? 0 : Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: Theme.paddingSmall
                        width: settings.showItemIconsInList ? page.width - Theme.iconSizeMedium - (Theme.horizontalPageMargin * 2) : page.width - (Theme.horizontalPageMargin * 2)
                        truncationMode: TruncationMode.Fade
                        text: title
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                    }

                    onClicked: {

                        loadingItemBusy.running = true;

                        if (settings.tapToCopy && templateUuid === "LOGIN") {

                            allItemDetails = false;
                            itemCopied = title;
                            getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultId, "--reveal", "--session", currentSession]);

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
                            getPassword.start("op", ["item", "get", uuid, "--fields", "label=password", "--vault", itemVaultId, "--reveal", "--session", currentSession]);

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

                // issues with trim not working when directly applying it to prelimOutput
                passwordStr = prelimOutput;
                passwordStr = passwordStr.trim();
                Clipboard.text = passwordStr;
                passwordStr = "";
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
