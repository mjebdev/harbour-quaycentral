# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-quaycentral

CONFIG += sailfishapp

SOURCES += src/harbour-quaycentral.cpp

DISTFILES += qml/harbour-quaycentral.qml \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/ItemDetails.qml \
    qml/pages/Items.qml \
    qml/pages/LargeType.qml \
    qml/pages/Settings.qml \
    qml/pages/SignIn.qml \
    qml/pages/Vaults.qml \
    rpm/harbour-quaycentral.changes.in \
    rpm/harbour-quaycentral.changes.run.in \
    rpm/harbour-quaycentral.spec \
    rpm/harbour-quaycentral.yaml \
    translations/*.ts \
    harbour-quaycentral.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172 256x256

# to disable building translations every time, comment out the
# following CONFIG line
# CONFIG += sailfishapp_i18n

QT += core

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.

# intending to add translations, none as of yet.
# TRANSLATIONS += translations/harbour-quaycentral-de.ts

HEADERS += src/process.h
