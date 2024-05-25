import QtQuick 2.6
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {

    id: page
    allowedOrientations: Orientation.PortraitMask

    SilicaFlickable {

        id: chooseVisibleCategories
        anchors.fill: parent
        contentHeight: vaultsPageCatListColumn.height

        Column {

            id: vaultsPageCatListColumn

            anchors {

                left: parent.left
                right: parent.right

            }

            PageHeader {

                title: qsTr("Select Categories")

            }

            BackgroundItem { // Avoiding a repeater/model method for now due to the way settings need to be synced etc. Hope to update with more efficient method of applying settings here, i.e. some kind of an array for settings.

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    enabled: false // Leaving as always-on to avoid empty Vault listing.
                    checked: true
                    text: qsTr("Logins")

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("API Credentials")
                    checked: settings.vaultPageDisplayApiCredential

                    onCheckedChanged: {

                        categoryListModel.set(1, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayApiCredential = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Bank Accounts")
                    checked: settings.vaultPageDisplayBankAccount

                    onCheckedChanged: {

                        categoryListModel.set(2, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayBankAccount = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Credit Cards")
                    checked: settings.vaultPageDisplayCreditCard

                    onCheckedChanged: {

                        categoryListModel.set(3, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayCreditCard = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Databases")
                    checked: settings.vaultPageDisplayDatabase

                    onCheckedChanged: {

                        categoryListModel.set(4, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayDatabase = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Documents")
                    checked: settings.vaultPageDisplayDocument

                    onCheckedChanged: {

                        categoryListModel.set(5, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayDocument = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Driver Licenses")
                    checked: settings.vaultPageDisplayDriverLicense

                    onCheckedChanged: {

                        categoryListModel.set(6, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayDriverLicense = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Email Accounts")
                    checked: settings.vaultPageDisplayEmailAccount

                    onCheckedChanged: {

                        categoryListModel.set(7, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayEmailAccount = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Identities")
                    checked: settings.vaultPageDisplayIdentity

                    onCheckedChanged: {

                        categoryListModel.set(8, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayIdentity = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Memberships")
                    checked: settings.vaultPageDisplayMembership

                    onCheckedChanged: {

                        categoryListModel.set(9, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayMembership = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Outdoor Licenses")
                    checked: settings.vaultPageDisplayOutdoorLicense

                    onCheckedChanged: {

                        categoryListModel.set(10, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayOutdoorLicense = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Passports")
                    checked: settings.vaultPageDisplayPassport

                    onCheckedChanged: {

                        categoryListModel.set(11, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayPassport = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Passwords")
                    checked: settings.vaultPageDisplayPassword

                    onCheckedChanged: {

                        categoryListModel.set(12, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayPassword = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Reward Programs")
                    checked: settings.vaultPageDisplayRewardProgram

                    onCheckedChanged: {

                        categoryListModel.set(13, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayRewardProgram = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Secure Notes")
                    checked: settings.vaultPageDisplaySecureNote

                    onCheckedChanged: {

                        categoryListModel.set(14, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplaySecureNote = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Servers")
                    checked: settings.vaultPageDisplayServer

                    onCheckedChanged: {

                        categoryListModel.set(15, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayServer = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Social Security Numbers")
                    checked: settings.vaultPageDisplaySocialSecurityNumber

                    onCheckedChanged: {

                        categoryListModel.set(16, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplaySocialSecurityNumber = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Software Licenses")
                    checked: settings.vaultPageDisplaySoftwareLicense

                    onCheckedChanged: {

                        categoryListModel.set(17, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplaySoftwareLicense = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("SSH Keys")
                    checked: settings.vaultPageDisplaySshKey

                    onCheckedChanged: {

                        categoryListModel.set(18, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplaySshKey = checked;
                        settings.sync();

                    }

                }

            }

            BackgroundItem {

                width: parent.width

                TextSwitch {

                    x: Theme.horizontalPageMargin
                    text: qsTr("Wireless Routers")
                    checked: settings.vaultPageDisplayWirelessRouter

                    onCheckedChanged: {

                        categoryListModel.set(19, {"includeOnVaultsPage": checked});
                        settings.vaultPageDisplayWirelessRouter = checked;
                        settings.sync();

                    }

                }

            }

            Row {

                width: parent.width
                height: Theme.paddingLarge

            }

        }

    }

}
    
