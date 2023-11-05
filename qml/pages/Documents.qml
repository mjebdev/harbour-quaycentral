import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Process 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property int searchFieldMargin
    property bool localDownloadFin: appWindow.downloadFin
    property bool localUploadFin: appWindow.uploadFin
    property bool localListingFin: appWindow.itemListingFin

    onLocalDownloadFinChanged: {

        if (localDownloadFin) {

            downloadingDocBusy.running = false;
            itemListView.enabled = true;

        }

    }

    onLocalUploadFinChanged: {

        if (localUploadFin) {

            // If still on this page, will refresh the list. If user has already swiped back, it's not necessary as list will be reloaded if they come back.
            if (docsInAllVaults) localRefreshDocsList.start("op", ["document", "list", "--format", "json", "--session", currentSession]);
            else localRefreshDocsList.start("op", ["document", "list", "--vault",  itemListModel.get(0).itemVaultId, "--format", "json", "--session", currentSession]);

        }

    }

    Process {

        id: localRefreshDocsList

        onReadyReadStandardOutput: {

            sessionExpiryTimer.restart();
            itemListModel.clear();
            itemSearchModel.clear();
            localRefreshDocsList.waitForFinished();
            var prelimOutput = readAllStandardOutput();
            var itemList = JSON.parse(prelimOutput);

            for (var i = 0; i < itemList.length; i++) {

                var createdDate = new Date(itemList[i].created_at);
                var updatedDate = new Date(itemList[i].created_at);

                if (itemList[i]["overview.ainfo"] !== null) itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: createdDate.toLocaleString(Locale.ShortFormat), docUpdatedAt: updatedDate.toLocaleString(Locale.ShortFormat), docAdditionalInfo: itemList[i]["overview.ainfo"]});
                else itemListModel.append({uuid: itemList[i].id, title: itemList[i].title, titleUpperCase: itemList[i].title.toUpperCase(), itemVaultId: itemList[i].vault.id, itemVaultName: itemList[i].vault.name, iconUrl: "image://theme/icon-m-file-document-dark", iconEmoji: "", docCreatedAt: createdDate.toLocaleString(Locale.ShortFormat), docUpdatedAt: updatedDate.toLocaleString(Locale.ShortFormat)});
                itemSearchModel.append(itemListModel.get(i));

            }

            uploadingDocBusy.running = false;
            itemListView.enabled = true;

        }

        onReadyReadStandardError: { // Shouldn't be any error happening, process only called right after upload complete, mainly here for possible unknown error.

            sessionExpiryTimer.stop();
            errorReadout = readAllStandardError();

            if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) {

                notifySessionExpired.previewSummary = qsTr("Session Expired");
                notifySessionExpired.publish();
                pageStack.completeAnimation();
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

            else {

                notifySessionExpired.previewSummary = qsTr("Unknown Error (copied to clipboard). Please sign back in.");
                notifySessionExpired.publish();
                Clipboard.text = errorReadout;
                pageStack.completeAnimation();
                pageStack.clear();
                pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

            }

        }

    }

    SilicaListView {

        id: itemListView
        currentIndex: -1
        model: itemSearchModel
        anchors.fill: parent

        PullDownMenu {

            MenuItem {

                text: qsTr("Lock")
                onClicked: lockItUp(false);
                visible: settings.includeLockMenuItem

            }

            MenuItem {

                text: qsTr("Upload Document")

                onClicked: {

                    pageStack.push(filePickerPage);

                }

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

                ListItem {

                    id: delegate

                    Icon {

                        id: docIcon
                        source: "image://theme/icon-m-file-document-dark"

                        anchors {

                            left: parent.left
                            leftMargin: searchFieldMargin - this.width - Theme.paddingMedium
                            verticalCenter: parent.verticalCenter

                        }

                    }

                    Label {

                        id: docName

                        anchors {

                            left: docIcon.right
                            leftMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter

                        }

                        text: title
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                    }

                    onClicked: {

                        if (menuOpen) closeMenu();
                        else openMenu();

                    }

                    menu: ContextMenu {

                        MenuItem {

                            enabled: false
                            height: Theme.itemSizeLarge + Theme.paddingMedium

                            Row {

                                width: parent.width
                                height: parent.height

                                Column {

                                    width: parent.width * 0.5
                                    height: parent.height

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.05
                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.3

                                        Label {

                                            width: parent.width
                                            height: parent.height
                                            verticalAlignment: "AlignVCenter"
                                            horizontalAlignment: "AlignRight"
                                            font.pixelSize: Theme.fontSizeExtraSmall
                                            color: Theme.secondaryColor
                                            rightPadding: Theme.paddingSmall
                                            text: qsTr("Created:")

                                        }

                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.3

                                        Label {

                                            width: parent.width
                                            height: parent.height
                                            verticalAlignment: "AlignVCenter"
                                            horizontalAlignment: "AlignRight"
                                            font.pixelSize: Theme.fontSizeExtraSmall
                                            color: Theme.secondaryColor
                                            rightPadding: Theme.paddingSmall
                                            text: qsTr("Last updated:")

                                        }

                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.3

                                        Label {

                                            width: parent.width
                                            height: parent.height
                                            verticalAlignment: "AlignVCenter"
                                            horizontalAlignment: "AlignRight"
                                            font.pixelSize: Theme.fontSizeExtraSmall
                                            color: Theme.secondaryColor
                                            rightPadding: Theme.paddingSmall
                                            text: qsTr("Additional info:")

                                        }

                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.05
                                    }

                                }

                                Column {

                                    width: parent.width * 0.5
                                    height: parent.height

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.05
                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.3

                                        Label {

                                            width: parent.width
                                            height: parent.height
                                            verticalAlignment: "AlignVCenter"
                                            horizontalAlignment: "AlignLeft"
                                            font.pixelSize: Theme.fontSizeExtraSmall
                                            color: Theme.secondaryColor
                                            leftPadding: Theme.paddingSmall
                                            text: docCreatedAt

                                        }

                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.3

                                        Label {

                                            width: parent.width
                                            height: parent.height
                                            verticalAlignment: "AlignVCenter"
                                            horizontalAlignment: "AlignLeft"
                                            font.pixelSize: Theme.fontSizeExtraSmall
                                            color: Theme.secondaryColor
                                            leftPadding: Theme.paddingSmall
                                            text: docUpdatedAt

                                        }
                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.3

                                        Label {

                                            width: parent.width
                                            height: parent.height
                                            verticalAlignment: "AlignVCenter"
                                            horizontalAlignment: "AlignLeft"
                                            font.pixelSize: Theme.fontSizeExtraSmall
                                            color: Theme.secondaryColor
                                            leftPadding: Theme.paddingSmall
                                            text: docAdditionalInfo

                                        }

                                    }

                                    Row {

                                        width: parent.width
                                        height: parent.height * 0.05
                                    }

                                }

                            }

                        }

                        MenuItem {

                            text: "Download"

                            onClicked: {

                                downloadingDocBusy.running = true;
                                documentDownloading = title;
                                mainGetDocument.start("op", ["document", "get", uuid, "--output", downloadsPath + "/" + title, "--session", currentSession]);
                                itemListView.enabled = false;
                                
                            }

                        }

                    }

                }

            }

        }

        VerticalScrollDecorator { }

    }

    Component {

        id: filePickerPage

        FilePickerPage {

            title: "Upload Document"

            onSelectedContentPropertiesChanged: {

                itemListView.enabled = false;
                documentUploading = selectedContentProperties.fileName;
                uploadingDocBusy.running = true;
                if (docsInAllVaults) mainUploadDocument.start("op", ["document", "create", selectedContentProperties.filePath, "--session", currentSession]);
                else mainUploadDocument.start("op", ["document", "create", selectedContentProperties.filePath, "--vault", itemListModel.get(0).itemVaultId, "--session", currentSession]);

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

    PageBusyIndicator {

        id: gettingDocListBusy
        running: !localListingFin

    }

    BusyLabel {

        id: downloadingDocBusy
        anchors.centerIn: parent
        running: false
        text: "Downloading '" + documentDownloading + "'..."

    }

    BusyLabel {

        id: uploadingDocBusy
        anchors.centerIn: parent
        running: false
        text: "Uploading '" + documentUploading + "'..."

    }

}
