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

    Q_INVOKABLE void commandWithPipedInput(const QString &program1, const QVariantList &arguments1, const QString &program2, const QVariantList &arguments2) {

        // Thanks to leemes on StackOverflow for providing an example of simulated piped input using QProcess.
        // https://stackoverflow.com/questions/10701504/command-working-in-terminal-but-not-via-qprocess

        QStringList args1;
        for (int i = 0; i < arguments1.length(); i++) args1 << arguments1[i].toString();
        QStringList args2;
        for (int i = 0; i < arguments2.length(); i++) args2 << arguments2[i].toString();
        QProcess command1;
        QProcess command2;
        command1.setStandardOutputProcess(&command2);
        command1.start(program1, args1);
        command2.start(program2, args2);
        command2.waitForFinished();
        QByteArray standardOutput = command2.readAllStandardOutput();
        QByteArray standardError = command2.readAllStandardError();
        command1.close();
        command2.close();
        newItemFinished(standardOutput, standardError);

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

signals:

    void newItemFinished(QByteArray standardOutput, QByteArray standardError);

};

#endif // PROCESS_H
