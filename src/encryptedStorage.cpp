#include "encryptedStorage.h"

#ifdef QT_DEBUG
#include <QDebug>
#endif

using namespace Sailfish::Secrets;

EncryptedStorage::EncryptedStorage(QObject *parent) : QObject(parent) { }

bool checkResult(const Request &req) {

    auto result = req.result();
    auto success = result.errorCode() == Result::NoError;

    if (!success) {

        #ifdef QT_DEBUG
        qDebug() << result.errorMessage();
        #endif

    }

    return success;

}

Secret::Identifier defaultVaultUUID(const QString &name) {

    return Secret::Identifier(name, QString(), SecretManager::DefaultStoragePluginName);

}

bool EncryptedStorage::storeData(const QString &key, const QByteArray &uuid) {

    Secret secret(defaultVaultUUID(key));
    secret.setData(uuid);
    StoreSecretRequest ssr;
    ssr.setManager(m_manager);
    ssr.setSecretStorageType(StoreSecretRequest::StandaloneDeviceLockSecret);
    ssr.setDeviceLockUnlockSemantic(SecretManager::DeviceLockKeepUnlocked);
    ssr.setAccessControlMode(SecretManager::OwnerOnlyMode);
    ssr.setEncryptionPluginName(SecretManager::DefaultEncryptionPluginName);
    ssr.setUserInteractionMode(SecretManager::SystemInteraction);
    ssr.setSecret(secret);
    ssr.startRequest();
    ssr.waitForFinished();

    return checkResult(ssr);

}

QByteArray EncryptedStorage::getUUID(const QString &key) {

    StoredSecretRequest ssr;
    ssr.setManager(m_manager);
    ssr.setUserInteractionMode(SecretManager::SystemInteraction);
    ssr.setIdentifier(defaultVaultUUID(key));;
    ssr.startRequest();
    ssr.waitForFinished();
    auto success = checkResult(ssr);

    if (success) {

        return ssr.secret().data();

    }

    return QByteArray();

}

bool EncryptedStorage::removeSecret() {

    DeleteSecretRequest dcr;
    dcr.setManager(m_manager);
    dcr.setIdentifier(defaultVaultUUID("Default Vault UUID"));
    dcr.setUserInteractionMode(SecretManager::SystemInteraction);
    dcr.startRequest();
    dcr.waitForFinished();

    return checkResult(dcr);

}
