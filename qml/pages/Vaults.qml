import QtQuick 2.0
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

            /* -- swipe back motion easier to lock
            MenuItem {

                text: "Lock"

                onClicked: {

                    lockItUp(false);

                }

            }
            */

        }

        header: PageHeader {

            title: qsTr("Vaults")

        }

        delegate: BackgroundItem {

            id: delegate

            Label {

                x: Theme.horizontalPageMargin
                text: name
                font.pixelSize: Theme.fontSizeMedium
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                padding: Theme.paddingMedium

            }

            onClicked: {

                gatheringBusy.running = true;
                mainProcess.start("op", ["list", "items", "--categories", "Login", "--vault", uuid, "--session", currentSession, "--cache"]);

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
            pageStack.push(Qt.resolvedUrl("Items.qml"));

        }

        onReadyReadStandardError: {

            sessionExpiryTimer.stop();
            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("not currently signed in") !== -1) {

                gatheringBusy.running = false;
                notifySessionExpired.previewSummary = "Session has expired.";
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
