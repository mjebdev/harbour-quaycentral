#ifndef QCJSONFILE_H
#define QCJSONFILE_H

#include <QObject>
#include <QFile>
#include <QTextStream>
#include <QString>
#include <QDebug>

class QcJsonFile : public QFile {

    Q_OBJECT

public:

    explicit QcJsonFile() { }

    Q_INVOKABLE bool writeJsonFile(QByteArray jsonContent, QString homeFolder) {

        QFile fileToSave(homeFolder + "/quaycentraldraft.json");

        if (!fileToSave.exists()) qInfo() << "File doesn't already exist.";

        else {

            qInfo() << "File already exists. Deleting...";
            if (fileToSave.remove()) qInfo() << "File has been deleted.";

        }

        if (fileToSave.open(QIODevice::WriteOnly)) qInfo() << "Attempt to open fileToSave succeeded.";

        else {

            qInfo() << "Attempt to open fileToSave failed.";
            return false;

        }

        QTextStream jsonStream(&fileToSave);
        jsonStream << jsonContent;
        fileToSave.close();
        return true;

    }

    Q_INVOKABLE bool deleteNewItemDraft(QString filePath) {

        QFile removeMe(filePath);
        if (removeMe.remove()) return true;
        else return false;

    }

};

#endif // QCJSONFILE_H
