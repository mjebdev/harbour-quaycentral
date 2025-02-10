import QtQuick 2.6
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string itemCopied
    property bool allFavDetails

    Component.onCompleted: {

        categoryListModel.set(1, {"includeOnVaultsPage": settings.vaultPageDisplayApiCredential});
        categoryListModel.set(2, {"includeOnVaultsPage": settings.vaultPageDisplayBankAccount});
        categoryListModel.set(3, {"includeOnVaultsPage": settings.vaultPageDisplayCreditCard});
        categoryListModel.set(4, {"includeOnVaultsPage": settings.vaultPageDisplayDatabase});
        categoryListModel.set(5, {"includeOnVaultsPage": settings.vaultPageDisplayDocument});
        categoryListModel.set(6, {"includeOnVaultsPage": settings.vaultPageDisplayDriverLicense});
        categoryListModel.set(7, {"includeOnVaultsPage": settings.vaultPageDisplayEmailAccount});
        categoryListModel.set(8, {"includeOnVaultsPage": settings.vaultPageDisplayIdentity});
        categoryListModel.set(9, {"includeOnVaultsPage": settings.vaultPageDisplayMembership});
        categoryListModel.set(10, {"includeOnVaultsPage": settings.vaultPageDisplayOutdoorLicense});
        categoryListModel.set(11, {"includeOnVaultsPage": settings.vaultPageDisplayPassport});
        categoryListModel.set(12, {"includeOnVaultsPage": settings.vaultPageDisplayPassword});
        categoryListModel.set(13, {"includeOnVaultsPage": settings.vaultPageDisplayRewardProgram});
        categoryListModel.set(14, {"includeOnVaultsPage": settings.vaultPageDisplaySecureNote});
        categoryListModel.set(15, {"includeOnVaultsPage": settings.vaultPageDisplayServer});
        categoryListModel.set(16, {"includeOnVaultsPage": settings.vaultPageDisplaySocialSecurityNumber});
        categoryListModel.set(17, {"includeOnVaultsPage": settings.vaultPageDisplaySoftwareLicense});
        categoryListModel.set(18, {"includeOnVaultsPage": settings.vaultPageDisplaySshKey});
        categoryListModel.set(19, {"includeOnVaultsPage": settings.vaultPageDisplayWirelessRouter});

    }

    onStatusChanged: {

        if (status === PageStatus.Active) {

            otpDisplayedOnCover = false;
            itemListModel.clear();
            itemSearchModel.clear();
            appWindow.itemListingFin = false;

        }

    }

    SilicaListView {

        id: vaultListView
        model: vaultListModel
        anchors.fill: parent

        PullDownMenu {

            MenuItem {

                text: qsTr("Lock")
                onClicked: lockItUp(false);
                visible: settings.includeLockMenuItem

            }

            MenuItem {

                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"));

            }

            MenuItem {

                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"));

            }

        }

        header: Column {

            id: headerColumn
            width: parent.width

            PageHeader {

                id: vaultsPageHeader
                title: justOneVault ? qsTr("Vault") : qsTr("Vaults")

            }

            SilicaListView {

                model: favItemsModel
                width: parent.width
                visible: anyFavItems
                height: contentHeight

                header: SectionHeader {

                    text: qsTr("Favorite Items")

                }

                delegate: BackgroundItem {

                    Icon {

                        anchors {

                            left: parent.left
                            leftMargin: Theme.horizontalPageMargin
                            verticalCenter: parent.verticalCenter

                        }

                        id: favItemIcon
                        source: "image://theme/icon-s-favorite"
                        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor

                    }

                    Label {

                        anchors {

                            left: favItemIcon.right
                            leftMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter

                        }

                        text: itemTitle
                        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor

                    }

                    onClicked: {

                        gatheringBusy.running = true;

                        if (settings.tapToCopy && itemType === "LOGIN") {

                            allFavDetails = false;
                            itemCopied = itemTitle;
                            getFavorite.start("op", ["item", "get", itemId, "--fields", "label=password", "--vault", itemVaultId, "--reveal", "--session", currentSession]);

                        }

                        else {

                            allFavDetails = true;
                            itemDetailsModel.clear();
                            itemDetailsModel.set(0, {"itemId": itemId, "itemTitle": itemTitle, "itemType": itemType, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName, "itemFields": [{"fieldId": "", "fieldType": "", "fieldLabel": "", "fieldValue": "", "fieldOtp": ""}]});
                            getFavorite.start("op", ["item", "get", itemId, "--vault", itemVaultId, "--format", "json", "--session", currentSession]);

                        }

                    }

                    onPressAndHold: {

                        gatheringBusy.running = true;

                        if (settings.tapToCopy || itemType !== "LOGIN") {

                            allFavDetails = true;
                            itemDetailsModel.clear();
                            itemDetailsModel.set(0, {"itemId": itemId, "itemTitle": itemTitle, "itemType": itemType, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName, "itemFields": [{"fieldId": "", "fieldType": "", "fieldLabel": "", "fieldValue": "", "fieldOtp": ""}]});
                            getFavorite.start("op", ["item", "get", itemId, "--vault", itemVaultId, "--format", "json", "--session", currentSession]);

                        }

                        else {

                            allFavDetails = false;
                            itemCopied = itemTitle;
                            getFavorite.start("op", ["item", "get", itemId, "--fields", "label=password", "--vault", itemVaultId, "--reveal", "--session", currentSession]);

                        }

                    }

                }

            }

        }

        delegate: ExpandingSection {

            id: listOfCategories
            title: name
            expanded: justOneVault
            width: parent.width

            content.sourceComponent: Column {

                anchors {

                    left: parent.left
                    right: parent.right

                }

                Repeater {

                    model: categories
                    width: parent.width
                    id: categoryListView

                    delegate: BackgroundItem {

                        width: parent.width
                        visible: includeOnVaultsPage

                        Label {

                            x: Theme.horizontalPageMargin
                            text: categoryDisplayName
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: Theme.fontSizeMedium
                            width: parent.width
                            height: parent.height
                            rightPadding: Theme.paddingMedium
                            topPadding: Theme.paddingSmall
                            bottomPadding: Theme.paddingSmall

                        }

                        onClicked: {

                            itemCategoryListingType = categoryName;
                            gatheringBusy.running = true;

                            if (categoryName === "Document") {

                                itemCategoryListingType = "Document";

                                if (uuid === "ALL_VAULTS") {

                                    docsInAllVaults = true;
                                    mainProcess.start("op", ["document", "list", "--format", "json", "--session", currentSession]);

                                }

                                else {

                                    docsInAllVaults = false;
                                    mainProcess.start("op", ["document", "list", "--vault", uuid, "--format", "json", "--session", currentSession]);

                                }

                            }

                            else {

                                itemCategoryListingType = categoryName;
                                if (uuid === "ALL_VAULTS") mainProcess.start("op", ["item", "list", "--categories", categoryName, "--format", "json", "--session", currentSession]);
                                else mainProcess.start("op", ["item", "list", "--categories", categoryName, "--vault", uuid, "--format", "json", "--session", currentSession]);

                            }

                        }

                    }

                }

            }

        }

        VerticalScrollDecorator { }

    }

    Process {

        id: mainProcess

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();
            itemSearchModel.clear();
            mainProcess.waitForFinished();
            var prelimOutput = readAllStandardOutput();
            var itemList = JSON.parse(prelimOutput);

            for (var i = 0; i < itemList.length; i++) {

                if (itemList[i].category == null) {

                    var createdDate = new Date(itemList[i].created_at);
                    var updatedDate = new Date(itemList[i].created_at);

                    if (itemList[i]["overview.ainfo"] !== null) itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: createdDate.toLocaleString(Locale.ShortFormat), docUpdatedAt: updatedDate.toLocaleString(Locale.ShortFormat), docAdditionalInfo: itemList[i]["overview.ainfo"]});
                    else itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: createdDate.toLocaleString(Locale.ShortFormat), docUpdatedAt: updatedDate.toLocaleString(Locale.ShortFormat)});
                    itemSearchModel.append(itemListModel.get(i));

                }

                else {

                    switch (itemList[i].category) {

                    case "API_CREDENTIAL": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                        break;

                    case "BANK_ACCOUNT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🏦"});
                        break;

                    case "CREDIT_CARD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "💳"});
                        break;

                    case "CUSTOM": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""}); // Bitcoin emoji not showing up on SFOS.
                        break;

                    case "DATABASE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🗃️"});
                        break;

                    case "DRIVER_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🚘"});
                        break;

                    case "EMAIL_ACCOUNT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-mail", iconEmoji: ""});
                        break;
                    // ID among others to be included in default (contact card icon)
                    //case "IDENTITY": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                        //break;

                    case "LOGIN": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                        break;

                    case "MEDICAL_RECORD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "⚕️"});
                        break;

                    //case "MEMBERSHIP": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                        //break;

                    case "OUTDOOR_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🏕️"});
                        break;

                    case "PASSPORT": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🛂"});
                        break;

                    case "PASSWORD": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                        break;

                    case "REWARD_PROGRAM": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🎁"});
                        break;

                    case "SECURE_NOTE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-note", iconEmoji: ""});
                        break;

                    case "SERVER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "🖧"});
                        break;

                    //case "SOCIAL_SECURITY_NUMBER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                        //break;

                    case "SOFTWARE_LICENSE": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "", iconEmoji: "💾"});
                        break;

                    case "SSH_KEY": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-keys", iconEmoji: ""});
                        break;

                    case "WIRELESS_ROUTER": itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-wlan", iconEmoji: ""});
                        break;

                    default: // A catch-all for Identity, Membership and Social Security Number, as these will all have the same ID-card icon.
                        itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-vcard", iconEmoji: ""});

                    }

                    itemSearchModel.append(itemListModel.get(i));

                }

            }

            gatheringBusy.running = false;
            if (itemCategoryListingType === "Document") pageStack.push(Qt.resolvedUrl("Documents.qml"));
            else pageStack.push(Qt.resolvedUrl("Items.qml"));

        }

        onReadyReadStandardError: {

            sessionExpiryTimer.stop();
            errorReadout = readAllStandardError();
            gatheringBusy.running = false;

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) {

                gatheringBusy.running = false;
                notifySessionExpired.previewSummary = "Session Expired";
                notifySessionExpired.publish();
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

            else {

                gatheringBusy.running = false;
                notifySessionExpired.previewSummary = "Unknown Error (copied to clipboard). Please sign back in.";
                notifySessionExpired.publish();
                Clipboard.text = errorReadout;
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

        }

    }

    Process {

        id: getFavorite

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();
            var prelimOutput = readAllStandardOutput();

            if (allFavDetails) {

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

                prelimOutput = " " + prelimOutput + " "; // need to avoid error: TypeError: Property 'trim' of object [password string w/ new line at end] is not a function.
                prelimOutput = prelimOutput.trim();
                Clipboard.text = prelimOutput;
                vaultsPageNotification.previewSummary = qsTr("%1 password copied").arg(itemCopied);
                vaultsPageNotification.publish();

            }

            gatheringBusy.running = false; // can do this after the pageStack.push?

        }

        onReadyReadStandardError: {

            errorReadout = readAllStandardError();
            sessionExpiryTimer.stop();
            gatheringBusy.running = false;

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) lockItUp(true);

            else {

                vaultsPageNotification.previewSummary = qsTr("Unknown Error (copied to clipboard). Please sign back in.");
                vaultsPageNotification.publish();
                Clipboard.text = errorReadout;
                lockItUp(false);

            }

        }

    }

    BusyIndicator {

        id: gatheringBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: false

    }

    Notification {

        id: vaultsPageNotification
        isTransient: true
        expireTimeout: 1500

    }

}
    
