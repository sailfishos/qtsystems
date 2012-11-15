/****************************************************************************
**
** Copyright (C) 2012 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the QtSystems module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#ifndef QSERVICEREPLY_H
#define QSERVICEREPLY_H

#include "qserviceframeworkglobal.h"
#include "qservicemanager.h"

#include <QObject>
#include <QMetaObject>

QT_BEGIN_HEADER

QT_BEGIN_NAMESPACE

class QServiceReplyPrivate;

class Q_SERVICEFW_EXPORT QServiceReplyBase : public QObject
{
    Q_OBJECT
public:
    explicit QServiceReplyBase(QObject *parent = 0);
    virtual ~QServiceReplyBase();

    bool isFinished() const;
    bool isRunning() const;
    QServiceManager::Error error() const;

    QString request() const;
    void setRequest(const QString &request);

Q_SIGNALS:
    void started();
    void finished();
    void errorChanged();

protected:

private Q_SLOTS:
    void start();
    void finish();
    void setError(QServiceManager::Error error);
    virtual void setProxyObject(QObject *proxyObject) = 0;

private:
    friend class QServiceOperationProcessor;

    Q_DISABLE_COPY(QServiceReplyBase)

    QServiceReplyPrivate *d;
};

class QServiceReply : public QServiceReplyBase
{
    Q_OBJECT
    public:
    QServiceReply(QObject *parent = 0)
        : QServiceReplyBase(parent),
          m_proxyObject(0)
    {
        // nothing to do
    }

    ~QServiceReply()
    {
        // nothing to do
    }

    QObject *proxyObject() const
    {
        return m_proxyObject;
    }

    void setProxyObject(QObject *proxyObject)
    {
        m_proxyObject = proxyObject;
    }

private:
    QObject *m_proxyObject;
};

QT_END_NAMESPACE

QT_END_HEADER

#endif // QSERVICEREPLY_H