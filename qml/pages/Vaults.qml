import QtQuick 2.6
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string itemCopied

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
                title: anyFavItems ? qsTr("Home") : justOneVault ? qsTr("Vault") : qsTr("Vaults")

            }

            SilicaListView {

                model: favItemsModel
                width: parent.width
                visible: anyFavItems
                height: contentHeight

                header: SectionHeader {

                    text: qsTr("Favorites")

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

                footer: SectionHeader {

                    visible: anyFavItems
                    text: justOneVault ? qsTr("Vault") : qsTr("Vaults")

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

                            gatheringBusy.running = true;
                            if (uuid === "ALL_VAULTS") mainProcess.start("op", ["item", "list", "--categories", categoryName, "--format", "json", "--session", currentSession, "--cache"]);
                            else mainProcess.start("op", ["item", "list", "--categories", categoryName, "--vault", uuid, "--format", "json", "--session", currentSession, "--cache"]);

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
            itemListModel.clear();
            itemSearchModel.clear();
            mainProcess.waitForFinished();
            var prelimOutput = readAllStandardOutput();
            var itemList = JSON.parse(prelimOutput);

            for (var i = 0; i < itemList.length; i++) {

                itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name});
                itemSearchModel.append(itemListModel.get(i));

            }

            gatheringBusy.running = false;
            pageStack.push(Qt.resolvedUrl("Items.qml"));

        }

        onReadyReadStandardError: {

            sessionExpiryTimer.stop();
            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) {

                gatheringBusy.running = false;
                notifySessionExpired.previewSummary = qsTr("Session Expired");
                notifySessionExpired.publish();
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

            else {

                gatheringBusy.running = false;
                notifySessionExpired.previewSummary = qsTr("Unknown Error (copied to clipboard). Please sign back in.");
                notifySessionExpired.publish();
                Clipboard.text = errorReadout;
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

        }

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

                vaultsPageNotification.previewSummary = "Unknown Error (copied to clipboard). Please sign back in.";
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
