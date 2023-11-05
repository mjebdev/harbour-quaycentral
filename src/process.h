#ifndef PROCESS_H
#define PROCESS_H

// 'Running an external program, system command, or shell script from QML'
// Source: http://www.xargs.com/qml/process.html
// Copyright © 2015 John Temples

#include <QObject>
#include <QProcess>
#include <QVariant>
#include <QString>
#include <QStandardPaths>
#include <QFile>
#include <QDebug>

class Process : public QProcess {

    Q_OBJECT

public:

    QString downloadsFolder = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);

    Process(QObject *parent = 0) : QProcess(parent) { }

    Q_INVOKABLE QString getDownloadsPath() {

        return downloadsFolder;

    }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments) {

        QStringList args;

        for (int i = 0; i < arguments.length(); i++)

        args << arguments[i].toString();

        QProcess::start(program, args);

    }

    Q_INVOKABLE QByteArray readAll() {

        return QProcess::readAll();

    }

    Q_INVOKABLE qint64 write(QByteArray commandToRun) {

        return QIODevice::write(commandToRun);

    }

    Q_INVOKABLE QByteArray readAllStandardError() {

        return QProcess::readAllStandardError();

    }

    Q_INVOKABLE QByteArray readAllStandardOutput() {

        return QProcess::readAllStandardOutput();

    }

    Q_INVOKABLE bool waitForFinished() {

        return QProcess::waitForFinished();

    }

    Q_INVOKABLE QProcess::ExitStatus exitStatus() {

        return QProcess::exitStatus();

    }

};

#endif // PROCESS_H
