import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import QcJsonFile 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    property string newItemCategory: "Login" // Will be Login as default and user can then choose a different type of item.
    property string newItemCategoryDisplay: qsTr("Login")
    property string newItemCategoryJson
    property string newItemTitle: qsTr("New %1").arg(newItemCategoryDisplay)
    property string selectedVault

    Component.onCompleted: {

        fieldsListModel.clear();
        getTemplateProcess.start("op", ["item", "template", "get", "Login", "--session", currentSession]);
        // Login template unlikely to change but retrieving template from server each time has benefit of
        // ensuring any changes are automatically applied, as opposed to storing the templates and needing to check
        // for updates etc. Also, app needs to be online to save the item in any case.

    }

    ListModel {

        id: newItemCategoryListModel

        ListElement {categoryName: "Login"; categoryDisplayName: qsTr("Login")}
        ListElement {categoryName: "Wireless Router"; categoryDisplayName: qsTr("Wireless Router")}
        ListElement {categoryName: "Secure Note"; categoryDisplayName: qsTr("Secure Note")}

    }
/*
    ListModel { // Going with using a basic model for just the fields as the other values can be kept in variables.

        id: newItemModel

        ListElement {

            title: "";
            categoryDisplay: "";
            category: "";

            fields: [ ListElement {

                fieldId: "";
                type: "";
                purpose: "";
                label: "";
                value: "";

            }]

        }

    }
*/
    ListModel {

        id: plainVaultList

        ListElement {

            name: ""; uuid: ""

        }

    }

    ListModel {

        id: fieldsListModel

        ListElement {

            fieldId: "";
            fieldType: "";
            fieldPurpose: "";
            fieldLabel: "";
            fieldValue: "";

        }

    }

    SilicaListView {

        anchors.fill: parent
        model: fieldsListModel

        Timer {

            id: avoidPipedInputProcessFreeze
            interval: 900 // Avoiding the app freezing up when running the piped input commands. This delay will allow menu to move back up and BusyIndicator to be displayed.

            onTriggered: {

                var jsonString = "{\"title\":\"" + newItemTitle + "\", \"category\":\"" + newItemCategoryJson + "\",\"fields\":[";
                console.log("Testing QML StandardPaths (home): " + StandardPaths.home);
                var atLeastOneThingEntered = false;

                for (var i = 0; i < fieldsListModel.count; i++) {

                    if (fieldsListModel.get(i).fieldValue !== "" && fieldsListModel.get(i).fieldValue !== " ") { // Only add entries that have data to avoid creating an item with many blank entries unnecessarily.

                        atLeastOneThingEntered = true;
                        jsonString = jsonString + "{\"id\":\"" + fieldsListModel.get(i).fieldId + "\", \"type\":\"" + fieldsListModel.get(i).fieldType + "\", \"label\":\"" + fieldsListModel.get(i).fieldLabel + "\", \"value\":\"" + fieldsListModel.get(i).fieldValue + "\"},";

                    }

                }

                jsonString = jsonString.slice(0, jsonString.length - 1); // Remove last comma
                jsonString = jsonString + "]}";

                if (atLeastOneThingEntered) {

                    const homeFolder = StandardPaths.home;

                    if (writeJsonToDisk.writeJsonFile(jsonString, homeFolder)) {

                        // Wrote to json draft file successfully.
                        //if (justOneVault) newItemProcess.start("op", ["item", "create", "--template=quaycentraldraft.json", "--session", currentSession]);
                        //else newItemProcess.start("op", ["item", "create", "--template=quaycentraldraft.json", "--vault", selectedVault, "--session", currentSession]);
                        // File so named as to hopefully avoid any potential clashes with other apps' files.

                        if (justOneVault) newItemProcess.commandWithPipedInput("cat", ["quaycentraldraft.json"], "op", ["item", "create", "--format", "json", "--session", currentSession]);
                        else newItemProcess.commandWithPipedInput("cat", ["quaycentraldraft.json"], "op", ["item", "create", "--vault", selectedVault, "--format", "json", "--session", currentSession]);

                    }

                    else console.log("Could not write JSON file to disk.");
                    newItemPageNotifier.previewSummary = qsTr("Error saving temporary file to disk. Item was not saved.");
                    newItemPageNotifier.publish();

                }

                else {

                    console.log("User has not entered in any data, nothing to save.");
                    newItemPageNotifier.previewSummary = qsTr("Please add data to one or more entry fields before saving item.");
                    newItemPageNotifier.publish();

                }

            }

        }

        PushUpMenu {

            MenuItem {

                text: qsTr("Save Item")

                onClicked: {

                    pageBusy.text = qsTr("Saving...")
                    pageBusy.running = true;

                    var tempStr = fieldsListModel.get(fieldsListModel.count - 1).fieldValue;
                    tempStr = tempStr.replace(/\\/g, "\\");
                    tempStr = tempStr.replace(/\n/g, "\\n");
                    tempStr = tempStr.replace(/\"/g, "\\\"");
                    fieldsListModel.set(fieldsListModel.count - 1, {"fieldValue": tempStr}); // Notes will always be last field entry.

                    avoidPipedInputProcessFreeze.running = true; // 1 second before process starts, may adjust.

                    // Allows for pull-down menu to return off screen and for busy indicator to start. Due to piped-input
                    // process, app would previously freeze upon the selection of the menu item, holding menu open until
                    // the process (both parts) completed, with no busy indicator spinning.

                }

            }

        }

        header: Column {

            // to contain the page header and the two drop-downs for Vault (if applicable) and Item Type.
            id: headerColumn
            width: parent.width

            PageHeader {

                id: pageHeader
                title: qsTr("New %1").arg(newItemCategoryDisplay); // some languages may have the equivalent of 'new' after the item type so using arg.

            }

            Row {

                width: parent.width

                TextField {

                    id: editTitleField
                    width: parent.width
                    label: qsTr("Title")
                    labelVisible: false

                    onTextChanged: {

                        newItemTitle = text;

                    }

                }

            }

            Row {

                width: parent.width

                ComboBox {

                    id: newItemCategoryCombo
                    width: parent.width
                    label: qsTr("Item type")

                    menu: ContextMenu {

                        Repeater {

                            model: newItemCategoryListModel

                            MenuItem { // default will be Login

                                text: categoryDisplayName

                                onClicked: {

                                    pageBusy.text = qsTr("Loading Template...")
                                    pageBusy.running = true;
                                    fieldsListModel.clear();
                                    newItemCategory = categoryName; // for saving the item later
                                    newItemCategoryDisplay = categoryDisplayName; // for displaying in Header
                                    getTemplateProcess.start("op", ["item", "template", "get", categoryName, "--session", currentSession]);

                                }

                            }

                        }

                    }

                }

            }

            Row {

                width: parent.width

                ComboBox {

                    Component.onCompleted: {

                        if (!justOneVault) {

                            plainVaultList.clear(); // This model will not include an 'ALL_VAULTS' element.
                            var defaultVaultFound = false;
                            // If there is a default vault, trying to pre-select it in this drop-down menu.
                            for (var i = 1; i < vaultListModel.count; i++) { // i = 1 so as to miss the 1st entry "ALL_VAULTS"

                                plainVaultList.append(vaultListModel.get(i));

                                if (settings.defaultVaultUuid == vaultListModel.get(i).uuid) {

                                    defaultVaultFound = true;
                                    this.currentIndex = plainVaultList.count - 1;
                                    selectedVault = settings.defaultVaultUuid;

                                }

                            }

                            if (!defaultVaultFound) selectedVault = plainVaultList.get(0).uuid; // First one in model will be one shown in menu if no default.

                        }

                    }

                    id: newItemVaultCombo
                    width: parent.width
                    label: qsTr("Vault")
                    visible: !justOneVault

                    menu: ContextMenu {

                        Repeater {

                            model: plainVaultList // need to select default when page loads, like settings?

                            MenuItem {

                                text: name

                                onClicked: selectedVault = uuid;

                            }

                        }

                    }

                }

            }
/*
            Separator {

                width: parent.width - (Theme.horizontalPageMargin * 2)
                horizontalAlignment: Qt.AlignHCenter
                x: Theme.horizontalPageMargin
                color: Theme.highlightColor

            }
*/
            SectionHeader {

                text: qsTr("Fields")

            }

            Row {

                width: parent.width
                height: Theme.paddingLarge

            }

        }

        delegate: ListItem {

            // Manage the json first to convert to listmodels, then back to json once user has entered values. Leaving out the value object entirely
            // if user has not entered any value to avoid unnecessarily adding blank entries to the saved item.
            contentHeight: fieldId == "notesPlain" ? editTextArea.height : Theme.itemSizeMedium
            property int fieldsLevelIndex: index

            TextArea {

                id: editTextArea
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                visible: fieldId == "notesPlain"
                label: fieldLabel

                onTextChanged: {

                    fieldsListModel.set(index, {"fieldValue": text});

                }

            }

            TextField {

                id: editTextField
                width: parent.width
                visible: fieldType == "STRING" && fieldId != "notesPlain"
                label: fieldLabel
                anchors.verticalCenter: parent.verticalCenter
                wrapMode: fieldId == "notesPlain" ? TextInput.Wrap : TextInput.NoWrap

                onTextChanged: {

                    fieldsListModel.set(index, {"fieldValue": text});

                }

            }

            PasswordField {

                id: editPasswordField
                width: parent.width
                visible: fieldType == "CONCEALED"
                label: fieldLabel
                anchors.verticalCenter: parent.verticalCenter

                onTextChanged: {

                    fieldsListModel.set(index, {"fieldValue": text});

                }

            }

            ComboBox {

                id: editMenu
                width: parent.width
                visible: fieldType == "MENU"
                label: fieldLabel
                anchors.verticalCenter: parent.verticalCenter

                ListModel {

                    id: wifiRouterSecurity

                    ListElement {secLevel: qsTr("none selected")} // this is left in place if user makes no selection.
                    ListElement {secLevel: qsTr("No Security")}
                    ListElement {secLevel: qsTr("WPA3 Personal")}
                    ListElement {secLevel: qsTr("WPA3 Enterprise")}
                    ListElement {secLevel: qsTr("WPA2 Personal")}
                    ListElement {secLevel: qsTr("WPA2 Enterprise")}
                    ListElement {secLevel: "WPA"}
                    ListElement {secLevel: "WEP"}

                }

                menu: ContextMenu {

                    Repeater {

                        model: wifiRouterSecurity

                        delegate: MenuItem {

                            text: secLevel

                            onClicked: {

                                if (index == 0) fieldsListModel.set(fieldsLevelIndex, {"fieldValue": ""}); // 'none selected'
                                else fieldsListModel.set(fieldsLevelIndex, {"fieldValue": secLevel});

                            }

                        }

                    }

                }

            }

        }

        Process {

            id: newItemProcess

            onNewItemFinished: {

                if (standardError == "" || standardError == " ") {

                    // Go about deleting the temporary json file.

                    if (writeJsonToDisk.deleteNewItemDraft(StandardPaths.home + "/quaycentraldraft.json")) {

                        var itemDetails = JSON.parse(standardOutput);
                        newItemPageNotifier.previewSummary = qsTr("New item saved successfully.");
                        newItemPageNotifier.publish();
                        itemDetailsModel.clear();
                        itemDetailsModel.set(0, {"itemId": itemDetails.id, "itemTitle": itemDetails.title, "itemType": itemDetails.category, "itemVaultId": itemDetails.vault.id, "itemVaultName": itemDetails.vault.name, "itemFields": [{"fieldId": "", "fieldType": "", "fieldLabel": "", "fieldValue": "", "fieldOtp": ""}]});
                        itemDetailsModel.get(0).itemFields.clear();
                        for (var i = 0; i < itemDetails.fields.length; i++) if (itemDetails.fields[i].id !== "" && itemDetails.fields[i].value !== undefined) itemDetailsModel.get(0).itemFields.append({"fieldId": itemDetails.fields[i].id, "fieldType": itemDetails.fields[i].type, "fieldLabel": itemDetails.fields[i].label, "fieldValue": itemDetails.fields[i].value, "fieldOtp": itemDetails.fields[i].totp !== undefined ? itemDetails.fields[i].totp : ""});
                        if (itemDetails.urls !== undefined) for (var j = 0; j < itemDetails.urls.length; j++) itemDetailsModel.get(0).itemFields.append({"fieldId": "URL", "fieldType": "URL", "fieldLabel": itemDetails.urls[j].label, "fieldValue": itemDetails.urls[j].href, "fieldOtp": ""});
                        pageStack.replace(Qt.resolvedUrl("ItemDetails.qml"));

                    }

                    else {

                        console.log("Error deleting JSON draft file -- needs regular (stickier) notification with file path to item and instructing user to delete, as it would likely contain sensitive information.");
                        newItemPageNotifier.isTransient = false;
                        newItemPageNotifier.urgency = Notification.Critical;
                        newItemPageNotifier.previewSummary = qsTr("Unable to delete temporary file. Please delete manually: " + StandardPaths.home + "/quaycentraldraft.json");
                        newItemPageNotifier.body = qsTr("Please make sure that file containing new item details is deleted. File location: " + StandardPaths.home + "/quaycentraldraft.json");
                        newItemPageNotifier.publish();
                        newItemPageNotifier.isTransient = true; // back to defaults.
                        newItemPageNotifier.urgency = Notification.Normal;
                        newItemPageNotifier.body = "";
                        pageBusy.running = false;

                    }

                }

                else {

                    pageBusy.running = false;

                    if (standardError.indexOf("not currently signed in") !== -1 || standardError.indexOf("session expired") !== -1) lockItUp(true);

                    else {

                        pageBusy.running = false;
                        console.log("Error unrelated to authorization? Output is as follows: " + standardError);
                        newItemPageNotifier.previewSummary = "Error - " + standardError.slice(28); // Will skip past the date & time to only include the error text in the notification.
                        newItemPageNotifier.publish();

                    }

                }

            }

        }

        Process {

            id: getTemplateProcess

            onReadyReadStandardOutput: {

                // Model already cleared when new category chosen or when page first accessed.
                var jsonTemplate = readAllStandardOutput();
                var templateParsed = JSON.parse(jsonTemplate);
                newItemCategoryJson = templateParsed.category;
                for (var i = 0; i < templateParsed.fields.length; i++) if (templateParsed.fields[i].id != "notesPlain") fieldsListModel.append({"fieldId": templateParsed.fields[i].id, "fieldType": templateParsed.fields[i].type, "fieldPurpose": templateParsed.fields[i].purpose, "fieldLabel": templateParsed.fields[i].label, "fieldValue": templateParsed.fields[i].value});
                fieldsListModel.append({"fieldId": "notesPlain", "fieldType": "STRING", "fieldPurpose": "NOTES", "fieldLabel": qsTr("notes"), "fieldValue": ""}); // Place the Notes field last in the model, takes care of issue with TextArea expanding over field below and also Notes belongs at bottom of list (and can be at the top when JSON comes back).
                pageBusy.running = false;

            }

            onReadyReadStandardError: {

                errorReadout = readAllStandardError();
                pageBusy.running = false;

                if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) lockItUp(true);

                else {

                    pageBusy.running = false;
                    console.log("Error unrelated to authorization? Output is as follows: " + errorReadout);
                    newItemPageNotifier.previewSummary = "Error - " + errorReadout.slice(28); // Will skip past the date & time to only include the error text in the notification.
                    newItemPageNotifier.publish();

                }

            }

        }

        footer: Item {

            id: lowerPadding
            width: parent.width
            height: Theme.paddingLarge

        }

    }

    QcJsonFile {

        id: writeJsonToDisk

    }

    BusyLabel {

        anchors.centerIn: parent
        id: pageBusy
        running: true
        text: qsTr("Loading Template...")

    }

    Notification {

        id: newItemPageNotifier
        isTransient: true

    }

}
