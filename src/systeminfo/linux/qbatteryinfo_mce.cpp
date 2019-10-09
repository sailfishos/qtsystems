/****************************************************************************
**
** Copyright (C) 2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC.
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

#include "qbatteryinfo_mce_p.h"
#include <QDebug>

#include <qmcechargertype.h>
#include <qmcebatterystate.h>
#include <qmcebatterystatus.h>
#include <qmcebatterylevel.h>

QT_BEGIN_NAMESPACE

QBatteryInfoPrivate::QBatteryInfoPrivate(QBatteryInfo *parent)
    : QObject(parent)
    , m_isValid(false)
    , m_mceChargerType(new QMceChargerType(this))
    , m_mceBatteryState(new QMceBatteryState(this))
    , m_mceBatteryStatus(new QMceBatteryStatus(this))
    , m_mceBatteryLevel(new QMceBatteryLevel(this))
{
    init();
}

QBatteryInfoPrivate::QBatteryInfoPrivate(int, QBatteryInfo *parent)
    : QObject(parent)
    , m_isValid(false)
    , m_mceChargerType(new QMceChargerType(this))
    , m_mceBatteryState(new QMceBatteryState(this))
    , m_mceBatteryStatus(new QMceBatteryStatus(this))
    , m_mceBatteryLevel(new QMceBatteryLevel(this))
{
    init();
}

void QBatteryInfoPrivate::init()
{
    connect(m_mceChargerType, &QMceChargerType::typeChanged, this, &QBatteryInfoPrivate::onChargerTypeChanged);
    connect(m_mceChargerType, &QMceChargerType::validChanged, this, &QBatteryInfoPrivate::onValidChanged);
    connect(m_mceBatteryState, &QMceBatteryState::stateChanged, this, &QBatteryInfoPrivate::onBatteryStateChanged);
    connect(m_mceBatteryState, &QMceBatteryState::validChanged, this, &QBatteryInfoPrivate::onValidChanged);
    connect(m_mceBatteryStatus, &QMceBatteryStatus::statusChanged, this, &QBatteryInfoPrivate::onBatteryStatusChanged);
    connect(m_mceBatteryStatus, &QMceBatteryStatus::validChanged, this, &QBatteryInfoPrivate::onValidChanged);
    connect(m_mceBatteryLevel, &QMceBatteryLevel::percentChanged, this, &QBatteryInfoPrivate::onBatteryLevelChanged);
    connect(m_mceBatteryLevel, &QMceBatteryLevel::validChanged,this, &QBatteryInfoPrivate::onValidChanged);
}

void QBatteryInfoPrivate::onValidChanged()
{
    bool isValid = (m_mceChargerType->valid() && m_mceBatteryState->valid() && m_mceBatteryStatus->valid() && m_mceBatteryLevel->valid());
    if (m_isValid != isValid) {
        m_isValid = isValid;
        emit validChanged(m_isValid);
    }
}

void QBatteryInfoPrivate::onChargerTypeChanged()
{
    emit chargerTypeChanged(chargerType());
}

void QBatteryInfoPrivate::onBatteryStateChanged()
{
    emit chargingStateChanged(chargingState());
}

void QBatteryInfoPrivate::onBatteryStatusChanged()
{
    emit levelStatusChanged(levelStatus());
}

void QBatteryInfoPrivate::onBatteryLevelChanged()
{
    emit levelChanged(level());
}

bool QBatteryInfoPrivate::isValid() const
{
    return m_isValid;
}

QBatteryInfo::ChargerType QBatteryInfoPrivate::chargerType() const
{
    QBatteryInfo::ChargerType chargerType = QBatteryInfo::UnknownCharger;
    switch (m_mceChargerType->type()) {
    case QMceChargerType::None:
    case QMceChargerType::Other:
        break;
    case QMceChargerType::USB:
        chargerType = QBatteryInfo::USBCharger;
        break;
    case QMceChargerType::DCP:
    case QMceChargerType::HVDCP:
    case QMceChargerType::CDP:
        chargerType = QBatteryInfo::WallCharger;
        break;
    case QMceChargerType::Wireless:
        chargerType = QBatteryInfo::VariableCurrentCharger;
        break;
    }
    return chargerType;
}

QBatteryInfo::ChargingState QBatteryInfoPrivate::chargingState() const
{
    QBatteryInfo::ChargingState chargingState = QBatteryInfo::UnknownChargingState;
    switch (m_mceBatteryState->state()) {
    case QMceBatteryState::Unknown:
        break;
    case QMceBatteryState::Charging:
        chargingState = QBatteryInfo::Charging;
        break;
    case QMceBatteryState::Discharging:
    case QMceBatteryState::NotCharging:
        chargingState = QBatteryInfo::Discharging;
        break;
    case QMceBatteryState::Full:
        chargingState = QBatteryInfo::IdleChargingState;
        break;
    }
    return chargingState;
}

QBatteryInfo::LevelStatus QBatteryInfoPrivate::levelStatus() const
{
    QBatteryInfo::LevelStatus levelStatus = QBatteryInfo::LevelUnknown;
    switch (m_mceBatteryStatus->status()) {
    case QMceBatteryStatus::Empty:
        levelStatus = QBatteryInfo::LevelEmpty;
        break;
    case QMceBatteryStatus::Low:
        levelStatus = QBatteryInfo::LevelLow;
        break;
    case QMceBatteryStatus::Ok:
        levelStatus = QBatteryInfo::LevelOk;
        break;
    case QMceBatteryStatus::Full:
        levelStatus = QBatteryInfo::LevelFull;
        break;
    }
    return levelStatus;
}

int QBatteryInfoPrivate::level() const
{
    return m_mceBatteryLevel->percent();
}

int QBatteryInfoPrivate::batteryCount() const
{
    // only one battery is supported atm
    return 1;
}

int QBatteryInfoPrivate::batteryIndex() const
{
    // only one battery is supported atm
    return 0;
}

void QBatteryInfoPrivate::setBatteryIndex(int)
{
    // only one battery is supported atm
}

int QBatteryInfoPrivate::currentFlow() const
{
    // not supported atm
    return 0;
}

int QBatteryInfoPrivate::cycleCount() const
{
    // not supported atm
    return -1;
}

QBatteryInfo::Health QBatteryInfoPrivate::health() const
{
    // not supported atm
    return QBatteryInfo::HealthUnknown;
}

int QBatteryInfoPrivate::maximumCapacity() const
{
    // not supported atm
    return -1;
}

int QBatteryInfoPrivate::remainingCapacity() const
{
    // not supported atm
    return -1;
}

int QBatteryInfoPrivate::remainingChargingTime() const
{
    // not supported atm
    return -1;
}

float QBatteryInfoPrivate::temperature() const
{
    // not supported atm
    return float(qQNaN());
}

int QBatteryInfoPrivate::voltage() const
{
    // not supported atm
    return -1;
}

QT_END_NAMESPACE
