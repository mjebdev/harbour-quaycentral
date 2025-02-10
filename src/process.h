#ifndef PROCESS_H
#define PROCESS_H

// 'Running an external program, system command, or shell script from QML'
// Source: http://www.xargs.com/qml/process.html
// Copyright © 2015 John Temples

#include <QObject>
#include <QProcess>
#include <QProcessEnvironment>
#include <QVariant>
#include <QString>

class Process : public QProcess {

    Q_OBJECT

public:

    Process(QObject *parent = 0) : QProcess(parent) { }

    Q_INVOKABLE void start(const QString &program, const QVariantList &arguments) {

        QStringList args;
        for (int i = 0; i < arguments.length(); i++) args << arguments[i].toString();
        QProcess::start(program, args);

    }

    Q_INVOKABLE void startWithEnv(const QString &program, const QVariantList &arguments, const QString &sessionKey) {
// was trying to get creating an item to work.
        QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
        env.insert("OP_SESSION", sessionKey);
        env.insert("OP_DEBUG", "true");
        QStringList args;
        for (int i = 0; i < arguments.length(); i++) args << arguments[i].toString();
        QProcess::setProcessEnvironment(env);
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
