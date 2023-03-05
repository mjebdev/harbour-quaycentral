import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    id: cover
    allowResize: true

    Image {

        id: coverBackgroundIcon
        source: "BW_harbour-quaycentral.png"
        width: parent.height - (Theme.paddingMedium * 2)
        height: width
        fillMode: Image.PreserveAspectFit
        opacity: 0.15

        anchors {

            verticalCenter: parent.verticalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium

        }

    }

    ListView {

        id: otpListView
        model: otpModel

        anchors {

            top: parent.top
            left: parent.left
            right: parent.right
            bottom: coverActionArea.top

        }

        Label {

            id: lowerLabel
            anchors.centerIn: parent
            text: ""
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            opacity: 0.0
            font.pixelSize: cover.size === Cover.Large ? Theme.fontSizeLarge : Theme.fontSizeMedium

            Behavior on opacity {

                FadeAnimator {

                    duration: 250

                }

            }

        }

        delegate: Column {

            width: parent.width
            height: cover.height - coverActionArea.height
            visible: active && settings.otpOnCover

            onVisibleChanged: {

                if (visible) coverBackgroundIcon.opacity = 0.05;
                else coverBackgroundIcon.opacity = 0.15;

            }

            Row {

                id: topPaddingRow
                width: parent.width
                height: cover.size === Cover.Large ? (Theme.paddingLarge * 2) : Theme.paddingMedium

            }

            Row {

                width: cover.size === Cover.Large ? parent.width - (Theme.paddingLarge * 2) : parent.width - (Theme.paddingMedium * 2)
                height: (parent.height - otpTimerProgressBarRow.height - topPaddingRow.height) / 2
                x: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                Label {

                    id: otpLabel1
                    width: parent.width
                    text: otpPart1
                    textFormat: Text.AutoText
                    font.pixelSize: Theme.fontSizeHuge
                    font.letterSpacing: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    color: primaryColor ? Theme.highlightColor : Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    opacity: primaryColor ? 1.0 : 0.2
                    leftPadding: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    rightPadding: 0

                }

            }

            Row {

                width: cover.size === Cover.Large ? parent.width - (Theme.paddingLarge * 2) : parent.width - (Theme.paddingMedium * 2)
                height: (parent.height - otpTimerProgressBarRow.height - topPaddingRow.height) / 2
                x: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                Label {

                    id: otpLabel2
                    width: parent.width
                    text: otpPart2
                    textFormat: Text.AutoText
                    font.pixelSize: Theme.fontSizeHuge
                    font.letterSpacing: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    color: primaryColor ? Theme.highlightColor : Theme.primaryColor
                    horizontalAlignment: Text.AlignHCenter
                    opacity: primaryColor ? 1.0 : 0.2
                    leftPadding: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium // the font.letterSpacing value offsets horizontal centering somewhat
                    rightPadding: 0
                    topPadding: 0

                }

            }

            Row {

                id: otpTimerProgressBarRow
                width: cover.size === Cover.Large ? parent.width - (Theme.paddingLarge * 2) : parent.width - (Theme.paddingMedium * 2)
                height: cover.size === Cover.Large ? otpTimerProgressBar.height + (Theme.paddingLarge * 2) : otpTimerProgressBar.height + Theme.paddingMedium // putting a bit more space between bar and the lock button.
                x: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                ProgressBar {

                    id: otpTimerProgressBar
                    anchors.top: otpLabel2.bottom
                    width: parent.width
                    minimumValue: 0
                    maximumValue: 30
                    value: secondsLeft
                    leftMargin: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium
                    rightMargin: cover.size === Cover.Large ? Theme.paddingLarge : Theme.paddingMedium

                }

            }

        }

    }

    CoverActionList {

        id: coverActionList
        enabled: !otpDisplayedOnCover

        CoverAction {

            id: coverAction
            iconSource: "image://theme/icon-s-secure"

            onTriggered: {

                lowerLabel.text = lockItUp(false);
                lowerLabel.opacity = 1.0;
                lockedTextTimer.start();

            }

        }

    }

    CoverActionList {

        id: otpCoverActionList
        enabled: otpDisplayedOnCover

        CoverAction {

            id: backFromOtpPage
            iconSource: settings.lockButtonOnCover ? "image://theme/icon-s-secure" : "image://theme/icon-cover-cancel"

            onTriggered: {

                if (settings.lockButtonOnCover) {

                    otpModel.set(0, {"active": false});
                    otpModel.clear();
                    otpDisplayedOnCover = false;
                    mainOtpTimer.stop();
                    itemDetailsModel.clear();
                    lowerLabel.text = lockItUp(false);
                    lowerLabel.opacity = 1.0;
                    lockedTextTimer.start();

                }

                else {

                    otpModel.set(0, {"active": false});
                    otpModel.clear();
                    otpDisplayedOnCover = false;
                    mainOtpTimer.stop();
                    itemDetailsModel.clear();
                    pageStack.pop(itemsPageObject, PageStackAction.Immediate);

                }

            }

        }

        CoverAction {

            id: otpCopyButton
            iconSource: "image://theme/icon-s-clipboard"

            onTriggered: {

                Clipboard.text = otpModel.get(0).otp.trim();
                notifySessionExpired.previewSummary = qsTr("OTP Copied");
                notifySessionExpired.publish();

            }

        }

    }

    Timer {

        id: lockedTextTimer
        interval: 1000

        onTriggered: {

            lowerLabel.opacity = 0.0

        }

    }

}
