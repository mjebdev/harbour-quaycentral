import QtQuick 2.6
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string itemCopied

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

                        if (settings.tapToCopy && itemType === "LOGIN") {

                            gatheringBusy.running = true;
                            itemCopied = itemTitle;
                            getFavsItemPassword.start("op", ["item", "get", itemId, "--fields", "label=password", "--vault", itemVaultId, "--session", currentSession]);

                        }

                        else {

                            itemDetailsModel.set(0, {"itemId": itemId, "itemTitle": itemTitle, "itemType": itemType, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName});
                            pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                        }

                    }

                    onPressAndHold: {

                        if (settings.tapToCopy || itemType !== "LOGIN") {

                            itemDetailsModel.set(0, {"itemId": itemId, "itemTitle": itemTitle, "itemType": itemType, "itemVaultId": itemVaultId, "itemVaultName": itemVaultName});
                            pageStack.push(Qt.resolvedUrl("ItemDetails.qml"));

                        }

                        else {

                            gatheringBusy.running = true;
                            itemCopied = itemTitle;
                            getFavsItemPassword.start("op", ["item", "get", itemId, "--fields", "label=password", "--vault", itemVaultId, "--session", currentSession]);

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

                            if (categoryName === "Document") {

                                if (uuid === "ALL_VAULTS") {

                                    docsInAllVaults = true;
                                    itemCategoryListingType = "Document";
                                    mainGetItems.start("op", ["document", "list", "--format", "json", "--session", currentSession]);

                                }

                                else {

                                    docsInAllVaults = false;
                                    itemCategoryListingType = "Document";
                                    mainGetItems.start("op", ["document", "list", "--vault", uuid, "--format", "json", "--session", currentSession]);

                                }

                                pageStack.push(Qt.resolvedUrl("Documents.qml"));

                            }

                            else {

                                itemCategoryListingType = categoryName;
                                if (uuid === "ALL_VAULTS") mainGetItems.start("op", ["item", "list", "--categories", categoryName, "--format", "json", "--session", currentSession]);
                                else mainGetItems.start("op", ["item", "list", "--categories", categoryName, "--vault", uuid, "--format", "json", "--session", currentSession]);
                                pageStack.push(Qt.resolvedUrl("Items.qml"));

                            }

                        }

                    }

                }

            }

        }

        VerticalScrollDecorator { }

    }

    Process {

        id: getFavsItemPassword

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();
            var prelimOutput = readAllStandardOutput();
            prelimOutput = " " + prelimOutput + " "; // need to avoid error: TypeError: Property 'trim' of object [password string w/ new line at end] is not a function.
            prelimOutput = prelimOutput.trim();
            Clipboard.text = prelimOutput;
            vaultsPageNotification.previewSummary = qsTr("%1 password copied").arg(itemCopied);
            vaultsPageNotification.publish();
            gatheringBusy.running = false;

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
