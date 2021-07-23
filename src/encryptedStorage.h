#ifndef ENCRYPTEDSTORAGE_H
#define ENCRYPTEDSTORAGE_H

#include <QObject>
#include <QtQml>
#include <Sailfish/Secrets/secretmanager.h>
#include <Sailfish/Secrets/request.h>
#include <Sailfish/Secrets/result.h>
#include <Sailfish/Secrets/secret.h>
#include <Sailfish/Secrets/storesecretrequest.h>
#include <Sailfish/Secrets/storedsecretrequest.h>
#include <Sailfish/Secrets/deletesecretrequest.h>

// Solely for the storing of the default vault UUID, if applicable. User will need
// to have more than one vault and to then choose to assign a default in Settings.

class EncryptedStorage : public QObject {

    Q_OBJECT

public:

    explicit EncryptedStorage(QObject *parent = nullptr);

    bool isValid() const;
    bool storeData(const QString &key, const QByteArray &uuid);
    QByteArray getUUID(const QString &key);
    bool removeSecret();

    Q_INVOKABLE bool save(const QString &key, const QByteArray &uuid) {

        return storeData(key, uuid);

    }

    Q_INVOKABLE QByteArray get(QByteArray keyName) {

        return getUUID(keyName);

    }

    Q_INVOKABLE bool deleteSecret() {

        return removeSecret();

    }

private:

    Sailfish::Secrets::SecretManager *m_manager {new Sailfish::Secrets::SecretManager(this)};

};

#endif // ENCRYPTEDSTORAGE_H
