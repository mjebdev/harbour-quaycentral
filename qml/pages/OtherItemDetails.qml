import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property bool pageIncludesPassword
    property int secondsCountdown
    property string totpOutput

    SilicaListView {

        id: itemDetailsView
        anchors.fill: parent
        model: itemDetailsModel
        contentHeight: column.height

        VerticalScrollDecorator {

            flickable: itemDetailsView

        }

        PullDownMenu {

            visible: settings.includeLockMenuItem

            MenuItem {

                text: qsTr("Lock");
                onClicked: lockItUp(false);
                visible: settings.includeLockMenuItem

            }

            MenuItem {

                id: copyTotpMenu
                text: qsTr("Copy One-Time Password")
                visible: false

                onClicked: {

                    Clipboard.text = totpOutput;
                    detailsPageNotification.previewSummary = qsTr("Copied one-time password to clipboard");
                    detailsPageNotification.publish();

                }

            }

            MenuItem {

                text: qsTr("Copy Password")
                visible: itemDetailsModel.get(0).password === "" ? false : true

                onClicked: {

                    Clipboard.text = itemDetailsModel.get(0).password;
                    detailsPageNotification.previewSummary = qsTr("Copied password to clipboard");
                    detailsPageNotification.publish();

                }

            }

        }

        delegate: Column {

            id: column
            spacing: 0
            width: page.width
            height: titleHeader.height + paddingRow.height + fieldItemsView.height + Theme.paddingMedium

            anchors {

                top: parent
                left: parent
                right: parent

            }

            PageHeader {

                id: titleHeader
                title: itemTitle

            }

            Row {

                width: parent.width
                id: paddingRow
                height: Theme.paddingLarge

            }

            ListView {

                model: sectionDetailsModel
                width: parent.width
                height: contentHeight // page.height - titleHeader.height
                id: fieldItemsView
                spacing: Theme.paddingMedium
                interactive: false

                delegate: Row {

                    width: parent.width
                    spacing: 0

                    Component.onCompleted: {

                        if (fieldItemName === "ccnum") {

                            //if (settings.ccnumHidden) {

                                itemDetailsPasswordField.text = fieldItemValue.slice(0, 4) + " " + fieldItemValue.slice(4, 8) + " " + fieldItemValue.slice(8, 12) + " " + fieldItemValue.slice(12);
                                itemDetailsPasswordField.font.letterSpacing = 4;
                                passwordRow.visible = true;

                            //}
/*
                            else {

                                usernameField.text = fieldItemValue.slice(0, 4) + " " + fieldItemValue.slice(4, 8) + " " + fieldItemValue.slice(8, 12) + " " + fieldItemValue.slice(12);
                                usernameField.font.letterSpacing = 4;
                                usernameRow.visible = true;

                            }
*/
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

                                if (fieldItemName.slice(0, 5).toUpperCase() === "TOTP_") { // title is not always 'one-time password' (have an item that contains TOTP with this field blank), need to check beginning of name to be certain.

                                    totpRow.visible = true;

                                }

                                else {

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

                                        usernameField.text = qsTr("Line of Credit");
                                        break;

                                    case "money_market":

                                        usernameField.text = qsTr("Money Market");
                                        break;

                                    case "atm":

                                        usernameField.text = qsTr("ATM");
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
                        height: visibleChildren.height + Theme.paddingLarge
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
                                                detailsPageNotification.previewSummary = qsTr("Copied %1 to clipboard").arg(fieldItemTitle);
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
/*
                                        Text { // not yet available with this version of QtQuick

                                            textFormat: Text.MarkdownText

                                        }
*/
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
                                                detailsPageNotification.previewSummary = qsTr("Copied %1 to clipboard").arg(fieldItemTitle);
                                                detailsPageNotification.publish();

                                            }

                                        }

                                    }

                                }

                            }

                        }

                        Row {

                            width: parent.width
                            id: totpRow
                            visible: false
                            height: itemDetailsPasswordField.height + (Theme.paddingMedium * 2) // since text may not yet be filled in
                            spacing: 0

                            onVisibleChanged: {

                                if (visible) {

                                    if(itemsInAllVaults) getTotp.start("op", ["get", "totp", uuid, "--session", currentSession]);
                                    else getTotp.start("op", ["get", "totp", uuid, "--vault", itemsVault, "--session", currentSession]);

                                }

                            }

                            Timer {

                                id: totpTimer
                                interval: 500
                                repeat: true
                                triggeredOnStart: false

                                onTriggered: {

                                    var totpCurrentTime = new Date;
                                    secondsCountdown = totpCurrentTime.getSeconds();
                                    if (secondsCountdown > 29) secondsCountdown = secondsCountdown - 30;
                                    secondsCountdown = (secondsCountdown - 30) * -1;
                                    totpTimerField.text = secondsCountdown.toString();

                                }

                            }

                            Process {

                                id: getTotp

                                onReadyReadStandardOutput: {

                                    totpOutput = readAllStandardOutput();
                                    totpOutput = totpOutput.trim();

                                    if (copyTotpMenu.visible == false) { // if first time checking for totp in item

                                        copyTotpMenu.visible = true;
                                        totpTimer.start();

                                    }

                                    totpTextField.text = totpOutput.slice(0, 3) + " " + totpOutput.slice(3);
                                    totpTextField.color = Theme.primaryColor;
                                    totpTimerField.color = Theme.primaryColor;
                                    totpCopyButton.enabled = true;
                                    gatheringTotpBusy.running = false;
                                    sessionExpiryTimer.restart();

                                }

                                onReadyReadStandardError: {

                                    errorReadout = readAllStandardError();

                                    if (errorReadout.indexOf("does not contain a one-time password") === -1) { // else no action needed, totpRow remains invisible, timer just restarted by previous page.

                                        sessionExpiryTimer.stop();
                                        gatheringTotpBusy.running = false;

                                        if (errorReadout.indexOf("not currently signed in") !== -1 || errorReadout.indexOf("session expired") !== -1) detailsPageNotification.previewSummary = "Session Expired";

                                        else {

                                            // there have already been successful TOTP grabs, possible network error.
                                            detailsPageNotification.previewSummary = "Unknown Error (copied to clipboard) - Please check network and try signing in again.";
                                            Clipboard.text = errorReadout;

                                        }

                                        detailsPageNotification.publish();
                                        pageStack.clear();
                                        pageStack.replace(Qt.resolvedUrl("SignIn.qml"));

                                    }

                                }

                            }

                            Column {

                                height: parent.height
                                width: parent.width - passwordCopyButton.width - itemDetailsPasswordField.textLeftMargin - Theme.paddingMedium + (passwordCopyButton.width / 8)
                                spacing: 0

                                Row {

                                    width: parent.width
                                    spacing: Theme.paddingMedium

                                    TextField {

                                        id: totpTextField
                                        font.letterSpacing: 6
                                        text: ". . .  . . ."
                                        readOnly: true
                                        label: qsTr("one-time password")
                                        y: passwordCopyButton.width / 8
                                        width: parent.width - Theme.paddingMedium

                                        rightItem: Label {

                                            id: totpTimerField
                                            horizontalAlignment: Qt.AlignHCenter
                                            width: totpCopyButton.width * 0.75

                                            Rectangle {

                                                height: gatheringTotpBusy.height + (gatheringTotpBusy.y * 2)
                                                color: "transparent"
                                                opacity: 1.0
                                                radius: 20

                                                anchors {

                                                    top: parent.top
                                                    left: parent.left
                                                    right: parent.right

                                                }

                                                border {

                                                    id: totpTimerBorder
                                                    width: 3
                                                    color: Theme.highlightColor

                                                }

                                            }

                                            onTextChanged: {

                                                var digit = parseInt(text);

                                                if (digit < 11) {

                                                    totpTimerBorder.color = Theme.errorColor;

                                                }

                                                else {

                                                    totpTimerBorder.color = Theme.highlightColor;

                                                    if (digit === 30) {

                                                        gatheringTotpBusy.running = true;
                                                        totpTextField.color = "grey";
                                                        totpTimerField.color = "grey";
                                                        totpCopyButton.enabled = false;
                                                        if (itemsInAllVaults) getTotp.start("op", ["get", "totp", uuid, "--session", currentSession]);
                                                        else getTotp.start("op", ["get", "totp", uuid, "--vault", itemsVault, "--session", currentSession]);

                                                    }

                                                }

                                            }

                                            BusyIndicator {

                                                id: gatheringTotpBusy
                                                size: BusyIndicatorSize.Small
                                                anchors.centerIn: parent
                                                running: false

                                            }

                                        }

                                    }

                                }

                            }

                            Column {

                                height: parent.height
                                width: totpCopyButton.width
                                spacing: Theme.paddingMedium

                                Row {

                                    spacing: 0
                                    width: parent.width

                                    Image {

                                        id: totpCopyButton
                                        source: "image://theme/icon-m-clipboard"
                                        y: 0

                                        MouseArea {

                                            anchors.fill: parent

                                            onClicked: {

                                                Clipboard.text = totpOutput;
                                                detailsPageNotification.previewSummary = qsTr("Copied one-time password to clipboard");
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
                            height: websiteField.height + (Theme.paddingMedium * 2)
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

                                        // To avoid "Cannot open file. File was not found." error.
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

                                    TextArea {

                                        id: notesArea
                                        label: fieldItemTitle
                                        readOnly: true
                                        height: contentHeight
                                        text: fieldItemValue
                                        y: notesCopyButton.width / 8
                                        //autoScrollEnabled: true
                                        //wrapMode: Text.Wrap

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
                                                detailsPageNotification.previewSummary = qsTr("Copied %1 to clipboard").arg(fieldItemTitle);
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
