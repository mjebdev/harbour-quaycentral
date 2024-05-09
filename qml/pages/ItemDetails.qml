import QtQuick 2.0
import Sailfish.Silica 1.0
import Process 1.0
import Nemo.Notifications 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask
    property string localVarOtp: appWindow.varOtp
    property bool localVarOtpPrimaryColor: appWindow.varOtpPrimaryColor
    property int localVarOtpSecondsLeft: appWindow.varOtpSecondsLeft

    SilicaListView {

        id: itemDetailsView
        anchors.fill: parent
        model: itemDetailsModel
        contentHeight: page.height

        VerticalScrollDecorator {

            flickable: itemDetailsView

        }

        PullDownMenu {

            visible: itemDetailsModel.get(0).itemType === "LOGIN" ? true : settings.includeLockMenuItem ? true : false

            MenuItem {

                text: qsTr("Lock");
                onClicked: lockItUp(false);
                visible: settings.includeLockMenuItem

            }

            MenuItem {

                id: passwordLargeTypeMenu
                text: qsTr("Show Password in Large Type")
                visible: false

                onClicked: {

                    largeTypeModel.clear();
                    var pwdString = itemDetailsModel.get(0).itemPassword;

                    for (var i = 0; i < pwdString.length; i++) {

                        largeTypeModel.append({"character": pwdString.slice(i, i + 1)});

                    }

                    pageStack.push(Qt.resolvedUrl("LargeType.qml"));

                }

            }

            MenuItem {

                id: copyOtpMenu
                text: qsTr("Copy One-Time Password")
                visible: false

                onClicked: {

                    Clipboard.text = localVarOtp.trim();
                    detailsPageNotification.previewSummary = qsTr("Copied one-time password to clipboard");
                    detailsPageNotification.publish();

                }

            }

            MenuItem {

                id: copyPasswordMenu
                text: qsTr("Copy Password")
                visible: false

                onClicked: {

                    Clipboard.text = itemDetailsModel.get(0).itemPassword;
                    detailsPageNotification.previewSummary = qsTr("Copied password to clipboard");
                    detailsPageNotification.publish();

                }

            }

        }

        delegate: Column {

            id: column
            width: page.width
            height: titleHeader.height + paddingRow.height + fieldItemsView.height + notesHeaderRow.height + notesRow.height

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

                id: fieldItemsView
                model: itemFields
                width: parent.width
                height: contentHeight
                spacing: Theme.paddingMedium
                interactive: false

                delegate: Row {

                    width: parent.width

                    Component.onCompleted: {

                        if (fieldId === "username") {

                            usernameField.label = qsTr("username") // need to force this as output came up with odd and/or random labels
                            usernameField.text = fieldValue;
                            usernameRow.visible = true;

                        }

                        else if (fieldId === "password") {

                            itemDetailsModel.set(0, {"itemPassword": fieldValue});
                            copyPasswordMenu.visible = true;
                            itemDetailsPasswordField.label = qsTr("password") // see same reason for forcing username label above
                            passwordRow.visible = true;
                            passwordLargeTypeMenu.visible = true;

                        }

                        else if (fieldId === "notesPlain") {

                            if (fieldValue !== "") {

                                notesArea.text = fieldValue;
                                notesHeaderRow.visible = true;
                                notesRow.visible = true;

                            }

                        }

                        else {

                            switch (fieldType) {

                                case "OTP":

                                    varOtp = fieldOtp;
                                    varOtpActive = true;
                                    copyOtpMenu.visible = true;
                                    mainOtpTimer.start();
                                    otpRow.visible = true;
                                    if (settings.otpOnCover) otpDisplayedOnCover = true;
                                    break;

                                case "CONCEALED":

                                    passwordRow.visible = true;
                                    break;

                                case "URL":

                                    websiteRow.visible = true;
                                    break;

                                case "CREDIT_CARD_TYPE":

                                    switch (fieldValue) {

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

                                            usernameField.text = fieldValue;

                                    }

                                    usernameRow.visible = true;
                                    break;

                                case ("MENU"):

                                    switch (fieldValue) {

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

                                            usernameField.text = fieldValue.charAt(0).toUpperCase() + fieldValue.slice(1);

                                    }

                                    usernameRow.visible = true;
                                    break;

                                case ("MONTH_YEAR"):

                                    usernameField.text = fieldValue.slice(4) + "/" + fieldValue.slice(0, 4);
                                    usernameRow.visible = true;
                                    break;

                                case ("DATE"):

                                    var date = new Date(parseInt(fieldValue) * 1000);
                                    usernameField.text = date.toLocaleDateString(Locale.ShortFormat);
                                    usernameRow.visible = true;
                                    break;

                                default:

                                    usernameField.text = fieldValue;
                                    usernameRow.visible = true;

                            }

                        }

                    }

                    Column {

                        width: parent.width
                        height: visibleChildren.height + Theme.paddingLarge

                        Row {

                            width: parent.width
                            id: usernameRow
                            height: usernameField.height + (Theme.paddingMedium * 2)
                            visible: false

                            Column {

                                height: parent.height
                                width: parent.width - usernameCopyButton.width - usernameField.textLeftMargin - Theme.paddingMedium + (usernameCopyButton.width / 8)

                                Row {

                                    width: parent.width
                                    spacing: Theme.paddingMedium

                                    TextField {

                                        id: usernameField
                                        label: fieldLabel
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

                                    width: parent.width

                                    Image {

                                        id: usernameCopyButton
                                        source: "image://theme/icon-m-clipboard"
                                        y: 0

                                        MouseArea {

                                            anchors.fill: parent

                                            onClicked: {

                                                Clipboard.text = usernameField.text;
                                                detailsPageNotification.previewSummary = qsTr("Copied %1 to clipboard").arg(usernameField.label);
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
                            visible: false

                            Column {

                                height: parent.height
                                width: parent.width - passwordCopyButton.width - passwordLargeButton.width - itemDetailsPasswordField.textLeftMargin - (Theme.paddingMedium * 3)

                                Row {

                                    width: parent.width
                                    spacing: Theme.paddingMedium

                                    PasswordField {

                                        id: itemDetailsPasswordField
                                        readOnly: true
                                        text: fieldValue
                                        label: fieldLabel
                                        y: passwordCopyButton.width / 8

                                    }

                                }

                            }

                            Column {

                                height: parent.height
                                width: passwordLargeButton.width + (Theme.paddingMedium * 2) + (passwordCopyButton.width / 8)
                                spacing: Theme.paddingMedium

                                Row {

                                    width: parent.width

                                    Image {

                                        id: passwordLargeButton
                                        source: "image://theme/icon-m-search"
                                        y: 0

                                        MouseArea {

                                            anchors.fill: parent

                                            onClicked: {

                                                largeTypeModel.clear();
                                                var pwdString = itemDetailsPasswordField.text;

                                                for (var i = 0; i < pwdString.length; i++) {

                                                    largeTypeModel.append({"character": pwdString.slice(i, i + 1)});

                                                }

                                                pageStack.push(Qt.resolvedUrl("LargeType.qml"));

                                            }

                                        }

                                    }

                                }

                            }

                            Column {

                                height: parent.height
                                width: passwordCopyButton.width
                                spacing: Theme.paddingMedium

                                Row {

                                    width: parent.width

                                    Image {

                                        id: passwordCopyButton
                                        source: "image://theme/icon-m-clipboard"
                                        y: 0

                                        MouseArea {

                                            anchors.fill: parent

                                            onClicked: {

                                                Clipboard.text = fieldValue;
                                                detailsPageNotification.previewSummary = qsTr("Copied %1 to clipboard").arg(itemDetailsPasswordField.label);
                                                detailsPageNotification.publish();

                                            }

                                        }

                                    }

                                }

                            }

                        }

                        Row {

                            id: otpRow
                            width: parent.width
                            height: otpListView.height
                            visible: false

                            onVisibleChanged: {

                                if (visible) mainGetOtp.start("op", ["item", "get", itemDetailsModel.get(0).itemId, "--otp", "--vault", itemDetailsModel.get(0).itemVaultId, "--session", currentSession]);

                            }

                            ListView {

                                id: otpListView
                                model: otpModel
                                width: parent.width
                                height: itemDetailsPasswordField.height + (Theme.paddingMedium * 2)
                                interactive: false

                                delegate: Row {

                                    width: parent.width
                                    height: itemDetailsPasswordField.height + (Theme.paddingMedium * 2)

                                    Column {

                                        height: parent.height
                                        width: parent.width - passwordCopyButton.width - itemDetailsPasswordField.textLeftMargin - Theme.paddingMedium + (passwordCopyButton.width / 8)

                                        Row {

                                            width: parent.width
                                            spacing: Theme.paddingMedium

                                            TextField {

                                                id: otpTextField
                                                font.letterSpacing: 6
                                                text: localVarOtp.slice(0, 3) + " " + localVarOtp.slice(3);
                                                color: localVarOtpPrimaryColor ? Theme.primaryColor : "grey"
                                                readOnly: true
                                                label: qsTr("one-time password")
                                                y: passwordCopyButton.width / 8
                                                width: parent.width - Theme.paddingMedium

                                                rightItem: Label {

                                                    id: otpTimerField
                                                    horizontalAlignment: Qt.AlignHCenter
                                                    width: otpCopyButton.width * 0.75
                                                    color: localVarOtpPrimaryColor ? Theme.primaryColor : "grey"
                                                    text: localVarOtpSecondsLeft

                                                    Rectangle {

                                                        height: gatheringOtpBusy.height + (gatheringOtpBusy.y * 2)
                                                        color: "transparent"
                                                        opacity: 1.0
                                                        radius: 20

                                                        anchors {

                                                            top: parent.top
                                                            left: parent.left
                                                            right: parent.right

                                                        }

                                                        border {

                                                            id: otpTimerBorder
                                                            width: 3
                                                            color: localVarOtpSecondsLeft < 11 ? Theme.errorColor : Theme.highlightColor

                                                        }

                                                    }

                                                    BusyIndicator {

                                                        id: gatheringOtpBusy
                                                        size: BusyIndicatorSize.Small
                                                        anchors.centerIn: parent
                                                        running: !localVarOtpPrimaryColor

                                                    }

                                                }

                                            }

                                        }

                                    }

                                    Column {

                                        height: parent.height
                                        width: otpCopyButton.width
                                        spacing: Theme.paddingMedium

                                        Row {

                                            width: parent.width

                                            Image {

                                                id: otpCopyButton
                                                source: "image://theme/icon-m-clipboard"
                                                y: 0

                                                MouseArea {

                                                    anchors.fill: parent

                                                    onClicked: {

                                                        Clipboard.text = localVarOtp.trim(); // otpModel.get(0).otp.trim();
                                                        detailsPageNotification.previewSummary = qsTr("Copied one-time password to clipboard");
                                                        detailsPageNotification.publish();

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
                            id: websiteRow
                            height: websiteField.height + (Theme.paddingMedium * 2)
                            visible: false

                            TextArea {

                                id: websiteField
                                label: qsTr("website") // fieldLabel was sometimes 'website' and sometimes undefined.
                                readOnly: true
                                text: fieldValue
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

                    }

                }

            }

            Row {

                id: notesHeaderRow
                width: parent.width
                visible: false

                Column {

                    height: notesHeader.height
                    width: parent.width

                    SectionHeader {

                        id: notesHeader
                        text: qsTr("Notes")
                        topPadding: 0

                    }

                }

            }

            Row {

                id: notesRow
                width: parent.width
                visible: false
                height: notesArea.height + (Theme.paddingMedium * 2)

                Column {

                    height: parent.height
                    width: parent.width - notesCopyButton.width - notesArea.textLeftMargin - Theme.paddingMedium + (notesCopyButton.width / 8)

                    Row {

                        width: parent.width
                        spacing: Theme.paddingMedium

                        TextArea {

                            id: notesArea
                            readOnly: true
                            text: ""
                            y: notesCopyButton.width / 8

                        }

                    }

                }

                Column {

                    height: parent.height
                    width: notesCopyButton.width
                    spacing: Theme.paddingMedium

                    Row {

                        width: parent.width

                        Image {

                            id: notesCopyButton
                            source: "image://theme/icon-m-clipboard"
                            y: 0

                            MouseArea {

                                anchors.fill: parent

                                onClicked: {

                                    Clipboard.text = notesArea.text;
                                    detailsPageNotification.previewSummary = qsTr("Copied notes to clipboard");
                                    detailsPageNotification.publish();

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

    BusyIndicator {

        id: loadingDataBusy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: false

    }

}
