import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property int secondsCountdown
    property string totpOutput
    property int listViewFixedHeightFigure: 1300

    SilicaListView {

        id: itemDetailsView
        anchors.fill: parent
        contentHeight: column.height
        model: itemDetailsModel

        PullDownMenu {

            MenuItem {

                visible: settings.includeLockMenuItem
                text: qsTr("Lock");
                onClicked: lockItUp(false);

            }

            MenuItem {

                id: copyTotpMenu
                text: qsTr("Copy One-Time Password")
                visible: false

                onClicked: {

                    Clipboard.text = totpOutput;
                    detailsPageNotification.previewSummary = ("Copied one-time password to clipboard");
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
            //anchors.fill: parent
            spacing: 0
            width: page.width
            height: visibleChildren.height

            VerticalScrollDecorator { }

            Component.onCompleted: {

                if(itemsInAllVaults) getTotp.start("op", ["get", "totp", uuid, "--session", currentSession]);
                else getTotp.start("op", ["get", "totp", uuid, "--vault", itemsVault, "--session", currentSession]);

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

                    if (totpRow.visible == false) { // if first time checking for totp in item

                        totpRow.visible = true;
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

            PageHeader {

                id: titleHeader
                title: itemTitle

            }

            Row {

                width: parent.width
                id: paddingRow
                height: Theme.paddingLarge

            }

            Row {

                width: parent.width
                id: usernameRow
                height: usernameField.height + (Theme.paddingMedium * 2)
                spacing: 0

                Column {

                    height: parent.height
                    width: parent.width - usernameCopyButton.width - usernameField.textLeftMargin - Theme.paddingMedium + (usernameCopyButton.width / 8)
                    spacing: 0

                    Row {

                        width: parent.width
                        spacing: Theme.paddingMedium

                        TextField {

                            id: usernameField
                            label: qsTr("username")
                            readOnly: true
                            text: username
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

                                    Clipboard.text = username;
                                    detailsPageNotification.previewSummary = qsTr("Copied username to clipboard");
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
                            text: password
                            label: qsTr("password")
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

                                    Clipboard.text = password;
                                    detailsPageNotification.previewSummary = qsTr("Copied password to clipboard");
                                    detailsPageNotification.publish();

                                }

                            }

                        }

                    }

                }

            }

            // To account for difference in size between show-password button and the copy button (48x48 and 64x64 respectively),
            // nudging down the fields to align correctly with copy button (passwordCopyButton.width / 8).

            Row {

                width: parent.width
                id: totpRow
                visible: false
                height: itemDetailsPasswordField.height + (Theme.paddingMedium * 2) // since text may not yet be filled in
                spacing: 0

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
                            text: "/././. /././."
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
                visible: websiteField.text === "" ? false : true

                TextArea {

                    id: websiteField
                    label: qsTr("website")
                    readOnly: true
                    text: website
                    color: Theme.highlightColor
                    y: passwordCopyButton.width / 8

                    onClicked: {

                        if (text.slice(0, 4) !== "http") { // To avoid "Cannot open file. File was not found." error.

                            var needsHttp = "https://" + text;
                            Qt.openUrlExternally(needsHttp);

                        }

                        else Qt.openUrlExternally(text);

                    }

                }

            }

            Row {

                width: parent.width
                //height: 250 //visibleChildren.height

                Column {

                    id: fieldItemsColumn
                    y: Theme.paddingMedium
                    width: parent.width
                    height: fieldItemsView.contentHeight // listViewFixedHeightFigure + Theme.paddingLarge

                    ListView {

                        id: fieldItemsView
                        model: sectionDetailsModel
                        width: parent.width
                        interactive: false
                        spacing: Theme.paddingMedium
                        height: contentHeight
                        //height: page.height - titleHeader.height - paddingRow.height - usernameRow.height - passwordRow.height - totpRow.height - websiteRow.height
                        //y: titleHeader.height + paddingRow.height + usernameRow.height + passwordRow.height + websiteRow.height

                        delegate: Row {

                            width: parent.width
                            height: visibleChildren.height
                            spacing: 0

                            Component.onCompleted: {

                                if (fieldItemName === "ccnum") {

                                    //if (settings.ccnumHidden) {

                                        itemDetailsPasswordField2.text = fieldItemValue.slice(0, 4) + " " + fieldItemValue.slice(4, 8) + " " + fieldItemValue.slice(8, 12) + " " + fieldItemValue.slice(12);
                                        itemDetailsPasswordField2.font.letterSpacing = 4;
                                        passwordRow2.visible = true;

                                    //}
/*
                                    else {

                                        usernameField2.text = fieldItemValue.slice(0, 4) + " " + fieldItemValue.slice(4, 8) + " " + fieldItemValue.slice(8, 12) + " " + fieldItemValue.slice(12);
                                        usernameField2.font.letterSpacing = 4;
                                        usernameRow2.visible = true;

                                    }
*/
                                }

                                else if (fieldItemName === "cvv" || fieldItemName ===  "pin") {

                                    itemDetailsPasswordField2.font.letterSpacing = 4;
                                    passwordRow2.visible = true;

                                }

                                else if (fieldItemName === "website" || fieldItemName ===  "server" || fieldItemName ===  "publisher_website" ||
                                         fieldItemName ===  "provider_website" || fieldItemName ===  "admin_console_url" ||
                                         fieldItemName ===  "support_contact_url") {

                                    websiteRow2.visible = true;

                                }

                                else {

                                    switch (fieldItemKind) {

                                    case "concealed":

                                        if (fieldItemName.slice(0, 5).toUpperCase() !== "TOTP_") { // title is not always 'one-time password' (have an item that contains TOTP with this field blank), need to check beginning of name to be certain.

                                            passwordRow2.visible = true;

                                        }

                                        break;

                                    case "notesPlain":

                                        notesRow.visible = true;
                                        break;

                                    case "URL":
                                    case "url":

                                        websiteRow2.visible = true;
                                        break;

                                    case "cctype":

                                        switch (fieldItemValue) {

                                        case "mc":

                                            usernameField2.text = "Mastercard";
                                            break;

                                        case "amex":

                                            usernameField2.text = "American Express";
                                            break;

                                        case "visa":

                                            usernameField2.text = "Visa";
                                            break;

                                        case "diners":

                                            usernameField2.text = "Diners Club";
                                            break;

                                        case "carteblanche":

                                            usernameField2.text = "Carte Blanche";
                                            break;

                                        case "discover":

                                            usernameField2.text = "Discover";
                                            break;

                                        case "jcb":

                                            usernameField2.text = "JCB";
                                            break;

                                        case "maestro":

                                            usernameField2.text = "Maestro";
                                            break;

                                        case "visaelectron":

                                            usernameField2.text = "Visa Electron";
                                            break;

                                        case "laser":

                                            usernameField2.text = "Laser";
                                            break;

                                        case "unionpay":

                                            usernameField2.text = "UnionPay";
                                            break;

                                        default:

                                            usernameField2.text = fieldItemValue;

                                        }

                                        usernameRow2.visible = true;
                                        break;

                                    case "menu":

                                        if (fieldItemName === "accountType") {

                                            switch (fieldItemValue) {

                                            case "loc":

                                                usernameField2.text = "Line of Credit";
                                                break;

                                            case "money_market":

                                                usernameField2.text = "Money Market";
                                                break;

                                            case "atm":

                                                usernameField2.text = "ATM";
                                                break;

                                            default:

                                                usernameField2.text = fieldItemValue.charAt(0).toUpperCase() + fieldItemValue.slice(1);

                                            }

                                        }

                                        else {

                                            usernameField2.text = fieldItemValue;

                                        }

                                        usernameRow2.visible = true;
                                        break;

                                    case "monthYear":

                                        if (fieldItemValue !== 0) {

                                            usernameField2.text = fieldItemValue.toString();
                                            usernameField2.text = usernameField2.text.slice(4) + "/" + usernameField2.text.slice(0, 4);
                                            usernameRow2.visible = true;

                                        }

                                        break;

                                    case "date":

                                        if (fieldItemValue !== 0) {

                                            var date = new Date(fieldItemValue * 1000);
                                            usernameField2.text = date.toLocaleDateString(Locale.ShortFormat);
                                            usernameRow2.visible = true;

                                        }

                                        break;

                                    default: // all other types, simple textfield

                                        usernameField2.text = fieldItemValue;
                                        usernameRow2.visible = true;

                                    }

                                }

                            }

                            Column {

                                width: parent.width
                                height: visibleChildren.height
                                spacing: 0

                                Component.onCompleted: listViewFixedHeightFigure = listViewFixedHeightFigure + this.height;

                                Row {

                                    width: parent.width
                                    id: usernameRow2
                                    height: usernameField2.height + (Theme.paddingMedium * 2)
                                    spacing: 0
                                    visible: false

                                    Column {

                                        height: parent.height
                                        width: parent.width - usernameCopyButton2.width - usernameField2.textLeftMargin - Theme.paddingMedium + (usernameCopyButton2.width / 8)
                                        spacing: 0

                                        Row {

                                            width: parent.width
                                            spacing: Theme.paddingMedium

                                            TextField {

                                                id: usernameField2
                                                label: fieldItemTitle
                                                readOnly: true
                                                y: passwordCopyButton2.width / 8

                                            }

                                        }

                                    }

                                    Column {

                                        height: parent.height
                                        width: usernameCopyButton2.width
                                        spacing: Theme.paddingMedium

                                        Row {

                                            spacing: 0
                                            width: parent.width

                                            Image {

                                                id: usernameCopyButton2
                                                source: "image://theme/icon-m-clipboard"
                                                y: 0

                                                MouseArea {

                                                    anchors.fill: parent

                                                    onClicked: {

                                                        Clipboard.text = usernameField2.text;
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
                                    id: passwordRow2
                                    height: itemDetailsPasswordField2.height + (Theme.paddingMedium * 2)
                                    spacing: 0
                                    visible: false

                                    Column {

                                        height: parent.height
                                        width: parent.width - passwordCopyButton2.width - itemDetailsPasswordField2.textLeftMargin - Theme.paddingMedium + (passwordCopyButton2.width / 8)
                                        spacing: 0

                                        Row {

                                            width: parent.width
                                            spacing: Theme.paddingMedium

                                            PasswordField {

                                                id: itemDetailsPasswordField2
                                                readOnly: true
                                                text: fieldItemValue
                                                label: fieldItemTitle
                                                y: passwordCopyButton2.width / 8
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
                                        width: passwordCopyButton2.width
                                        spacing: Theme.paddingMedium

                                        Row {

                                            spacing: 0
                                            width: parent.width

                                            Image {

                                                id: passwordCopyButton2
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
                                    height: websiteField2.height + (Theme.paddingMedium * 2)
                                    id: websiteRow2
                                    visible: false

                                    TextArea {

                                        id: websiteField2
                                        label: fieldItemTitle
                                        readOnly: true
                                        text: fieldItemValue
                                        color: Theme.highlightColor
                                        y: passwordCopyButton2.width / 8

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

            Row {

                width: parent.width
                id: paddingRow2
                height: Theme.paddingMedium

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
