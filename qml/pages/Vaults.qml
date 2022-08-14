import QtQuick 2.6
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

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

        header: PageHeader {

            id: vaultsPageHeader
            title: qsTr("Vaults")

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
                            //itemsVault = uuid;

                            if (uuid === "ALL_VAULTS") {

                                //itemsInAllVaults = true;

                                mainProcess.start("op", ["item", "list", "--categories", categoryName, "--format", "json", "--session", currentSession, "--cache"]);

                            }

                            else {

                                //itemsInAllVaults = false;
                                //itemsVault = uuid;

                                mainProcess.start("op", ["item", "list", "--categories", categoryName, "--vault", uuid, "--format", "json", "--session", currentSession, "--cache"]);

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
            itemListModel.clear();
            itemSearchModel.clear();
            mainProcess.waitForFinished();
            var prelimOutput = readAllStandardOutput();
            itemList = JSON.parse(prelimOutput);

            for (var i = 0; i < itemList.length; i++) {

                itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), templateUuid: itemList[i].category, itemVaultID: itemList[i].vault.id, itemVaultName: itemList[i].vault.name});
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

    BusyIndicator {

        id: gatheringBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: false

    }

}
    
