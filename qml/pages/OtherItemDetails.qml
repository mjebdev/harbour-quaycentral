import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    SilicaListView {

        id: itemDetailsView
        anchors.fill: parent
        model: itemDetailsModel

        /*PullDownMenu {

            possible feature further on in development-
            MenuItem {

                text: "Edit"

                onClicked: {

                    //

                }

            }

        }*/

        PullDownMenu {

            MenuItem {

                text: qsTr("Lock");
                onClicked: lockItUp(false);

            }

        }

        delegate: Column {

            id: column
            anchors.fill: parent
            spacing: 0
            width: page.width
            height: page.height

            PageHeader {

                id: titleHeader
                title: itemTitle

            }

            ListView {

                model: sectionDetailsModel
                width: parent.width
                height: page.height - titleHeader.height
                id: fieldItemsView
                spacing: Theme.paddingMedium
                VerticalScrollDecorator{flickable: fieldItemsView}

                delegate: Row {

                    width: parent.width
                    //height: parent.height
                    spacing: 0

                    Component.onCompleted: {

                        if (fieldItemName === "ccnum") {

                            if (settings.ccnumHidden) {

                                itemDetailsPasswordField.text = fieldItemValue.slice(0, 4) + " " + fieldItemValue.slice(4, 8) + " " + fieldItemValue.slice(8, 12) + " " + fieldItemValue.slice(12);
                                itemDetailsPasswordField.font.letterSpacing = 4;
                                passwordRow.visible = true;

                            }

                            else {

                                usernameField.text = fieldItemValue.slice(0, 4) + " " + fieldItemValue.slice(4, 8) + " " + fieldItemValue.slice(8, 12) + " " + fieldItemValue.slice(12);
                                usernameField.font.letterSpacing = 4;
                                usernameRow.visible = true;

                            }

                        }

                        else if (fieldItemName === "cvv" || fieldItemName ===  "pin") {

                            itemDetailsPasswordField.font.letterSpacing = 4;
                            passwordRow.visible = true;

                        }

                        else if (fieldItemName === "website" || fieldItemName ===  "server" || fieldItemName ===  "publisher_website" ||
                                 fieldItemName ===  "provider_website" || fieldItemName ===  "admin_console_url" ||
                                 fieldItemName ===  "support_contact_url") {

                            websiteRow.visible = true;

                        }

                        else {

                            switch (fieldItemKind) {

                            case "concealed":

                                if (fieldItemTitle.toUpperCase() !== "ONE-TIME PASSWORD") {

                                    passwordRow.visible = true;

                                }

                                break;

                            case "notesPlain":

                                notesRow.visible = true;
                                break;

                            case "URL":
                            case "url":

                                websiteRow.visible = true;
                                break;

                            case "cctype":

                                switch (fieldItemValue) {

                                case "mc":

                                    usernameField.text = "Mastercard";
                                    break;

                                case "amex":

                                    usernameField.text = "American Express";
                                    break;

                                case "visa":

                                    usernameField.text = "Visa";
                                    break;

                                case "diners":

                                    usernameField.text = "Diners Club";
                                    break;

                                case "carteblanche":

                                    usernameField.text = "Carte Blanche";
                                    break;

                                case "discover":

                                    usernameField.text = "Discover";
                                    break;

                                case "jcb":

                                    usernameField.text = "JCB";
                                    break;

                                case "maestro":

                                    usernameField.text = "Maestro";
                                    break;

                                case "visaelectron":

                                    usernameField.text = "Visa Electron";
                                    break;

                                case "laser":

                                    usernameField.text = "Laser";
                                    break;

                                case "unionpay":

                                    usernameField.text = "UnionPay";
                                    break;

                                default:

                                    usernameField.text = fieldItemValue;

                                }

                                usernameRow.visible = true;
                                break;

                            case "menu":

                                if (fieldItemName === "accountType") {

                                    switch (fieldItemValue) {

                                    case "loc":

                                        usernameField.text = "Line of Credit";
                                        break;

                                    case "money_market":

                                        usernameField.text = "Money Market";
                                        break;

                                    case "atm":

                                        usernameField.text = "ATM";
                                        break;

                                    default:

                                        usernameField.text = fieldItemValue.charAt(0).toUpperCase() + fieldItemValue.slice(1);

                                    }

                                }

                                else {

                                    usernameField.text = fieldItemValue;

                                }

                                usernameRow.visible = true;
                                break;

                            case "monthYear":

                                if (fieldItemValue !== 0) {

                                    usernameField.text = fieldItemValue.toString();
                                    usernameField.text = usernameField.text.slice(4) + "/" + usernameField.text.slice(0, 4);
                                    usernameRow.visible = true;

                                }

                                break;

                            case "date":

                                if (fieldItemValue !== 0) {

                                    var date = new Date(fieldItemValue * 1000);
                                    usernameField.text = date.toLocaleDateString(Locale.ShortFormat);
                                    usernameRow.visible = true;

                                }

                                break;

                            default: // all other types, simple textfield

                                usernameField.text = fieldItemValue;
                                usernameRow.visible = true;

                            }

                        }

                    }

                    Column {

                        width: parent.width
                        height: visibleChildren.height
                        spacing: 0

                        Row {

                            width: parent.width
                            id: usernameRow
                            height: usernameField.height + (Theme.paddingMedium * 2)
                            spacing: 0
                            visible: false

                            Column {

                                height: parent.height
                                width: parent.width - usernameCopyButton.width - usernameField.textLeftMargin - Theme.paddingMedium + (usernameCopyButton.width / 8)
                                spacing: 0

                                Row {

                                    width: parent.width
                                    spacing: Theme.paddingMedium

                                    TextField {

                                        id: usernameField
                                        label: fieldItemTitle
                                        readOnly: true
                                        y: passwordCopyButton.width / 8

                                    }

                                }

                            }

                            Column {

                                height: parent.height
                                width: usernameCopyButton.width
                                spacing: Theme.paddingMedium

                                Row {

                                    spacing: 0
                                    width: parent.width

                                    Image {

                                        id: usernameCopyButton
                                        source: "image://theme/icon-m-clipboard"
                                        y: 0

                                        MouseArea {

                                            anchors.fill: parent

                                            onClicked: {

                                                Clipboard.text = usernameField.text;
                                                detailsPageNotification.previewSummary = qsTr("Copied")
                                                detailsPageNotification.publish();

                                            }

                                        }

                                    }

                                }

                            }

                        }

                        Row {

                            width: parent.width
                            id: passwordRow
                            height: itemDetailsPasswordField.height + (Theme.paddingMedium * 2)
                            spacing: 0
                            visible: false

                            Column {

                                height: parent.height
                                width: parent.width - passwordCopyButton.width - itemDetailsPasswordField.textLeftMargin - Theme.paddingMedium + (passwordCopyButton.width / 8)
                                spacing: 0

                                Row {

                                    width: parent.width
                                    spacing: Theme.paddingMedium

                                    PasswordField {

                                        id: itemDetailsPasswordField
                                        readOnly: true
                                        text: fieldItemValue
                                        label: fieldItemTitle
                                        y: passwordCopyButton.width / 8

                                    }

                                }

                            }

                            Column {

                                height: parent.height
                                width: passwordCopyButton.width
                                spacing: Theme.paddingMedium

                                Row {

                                    spacing: 0
                                    width: parent.width

                                    Image {

                                        id: passwordCopyButton
                                        source: "image://theme/icon-m-clipboard"
                                        y: 0

                                        MouseArea {

                                            anchors.fill: parent

                                            onClicked: {

                                                Clipboard.text = fieldItemValue;
                                                detailsPageNotification.previewSummary = qsTr("Copied")
                                                detailsPageNotification.publish();

                                            }

                                        }

                                    }

                                }

                            }

                        }

                        Row {

                            width: parent.width
                            id: websiteRow
                            visible: false

                            TextArea {

                                id: websiteField
                                label: fieldItemTitle
                                readOnly: true
                                text: fieldItemValue
                                color: Theme.highlightColor
                                y: passwordCopyButton.width / 8

                                onClicked: {

                                    if (text.slice(0, 4) !== "http") {

                                        // To avoid for "Cannot open file. File was not found." error.
                                        var needsHttp = "https://" + text;
                                        Qt.openUrlExternally(needsHttp);

                                    }

                                    else Qt.openUrlExternally(text);

                                }

                            }

                        }

                        Row {

                            width: parent.width
                            id: notesRow
                            height: notesArea.height + (Theme.paddingMedium * 2)
                            spacing: 0
                            visible: false

                            Column {

                                height: parent.height
                                width: parent.width - notesCopyButton.width - notesArea.textLeftMargin - Theme.paddingMedium + (notesCopyButton.width / 8)
                                spacing: 0

                                Row {

                                    width: parent.width
                                    spacing: Theme.paddingMedium

                                    TextField {

                                        id: notesArea
                                        label: fieldItemTitle
                                        readOnly: true
                                        text: fieldItemValue
                                        y: notesCopyButton.width / 8

                                    }

                                }

                            }

                            Column {

                                height: parent.height
                                width: notesCopyButton.width
                                spacing: Theme.paddingMedium

                                Row {

                                    spacing: 0
                                    width: parent.width

                                    Image {

                                        id: notesCopyButton
                                        source: "image://theme/icon-m-clipboard"
                                        y: 0

                                        MouseArea {

                                            anchors.fill: parent

                                            onClicked: {

                                                Clipboard.text = fieldItemValue;
                                                detailsPageNotification.previewSummary = qsTr("Copied")
                                                detailsPageNotification.publish();

                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

    Notification {

        id: detailsPageNotification
        appName: "QuayCentral"
        urgency: Notification.Low
        isTransient: true
        expireTimeout: 800

    }

}
