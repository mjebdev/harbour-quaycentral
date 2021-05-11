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

                text: qsTr("Settings")

                onClicked: {

                    pageStack.push(Qt.resolvedUrl("Settings.qml"));

                }

            }

        }

        header: PageHeader {

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

                            // for future item grabs (fewer calls if vault is specified) - vaultUUID array no longer in use as parsed JSON go-between,
                            // so can safely overwrite with data from ListModel each time a vault is chosen
                            vaultUUID[0] = uuid;
                            chosenCategory = categoryName;
                            gatheringBusy.running = true;
                            mainProcess.start("op", ["list", "items", "--categories", categoryName, "--vault", uuid, "--session", currentSession, "--cache"]);

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
            mainProcess.waitForFinished();
            var prelimOutput = readAllStandardOutput();
            itemList = JSON.parse(prelimOutput);

            for (var i = 0; i < itemList.length; i++) {

                itemTitle[i] = itemList[i].overview.title;
                itemTitleToUpperCase[i] = itemList[i].overview.title.toUpperCase();
                itemUUID[i] = itemList[i].uuid;
                itemListModel.append({uuid: itemUUID[i], title: itemTitle[i]});

            }

            gatheringBusy.running = false;
            if (chosenCategory == "Login") pageStack.push(Qt.resolvedUrl("Items.qml"));
            else pageStack.push(Qt.resolvedUrl("OtherItems.qml"));

        }

        onReadyReadStandardError: {

            sessionExpiryTimer.stop();
            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("not currently signed in") !== -1) {

                gatheringBusy.running = false;
                notifySessionExpired.previewSummary = "Session Expired";
                notifySessionExpired.publish();
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
