/****************************************************************************
**
** Copyright (C) 2014-2015 Jolla Ltd.
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

#include "qbatteryinfo_statefs_p.h"
#include <contextproperty.h>
#include <QDebug>

QT_BEGIN_NAMESPACE

#define QS_(str) QStringLiteral(str)

static QBatteryInfo::ChargerType chargerTypeFromName(QString const &name)
{
    static const QMap<QString, QBatteryInfo::ChargerType> types = {{
            {QS_("unknown"), QBatteryInfo::UnknownCharger}
            , {QS_(""), QBatteryInfo::UnknownCharger}
            , {QS_("dcp"), QBatteryInfo::WallCharger}
            , {QS_("usb"), QBatteryInfo::USBCharger}
            , {QS_("cdp"), QBatteryInfo::WallCharger}
        }};
    return types.value(name, QBatteryInfo::UnknownCharger);
}

static QBatteryInfo::ChargingState chargingStateFromName(QString const &name)
{
    static const QMap<QString, QBatteryInfo::ChargingState> states = {
        {QS_("unknown"), QBatteryInfo::UnknownChargingState }
        , {QS_("charging"), QBatteryInfo::Charging}
        , {QS_("discharging"), QBatteryInfo::Discharging}
        , {QS_("idle"), QBatteryInfo::IdleChargingState}
    };
    return states.value(name, QBatteryInfo::UnknownChargingState);
}

QBatteryInfoPrivate::QBatteryInfoPrivate(QBatteryInfo *parent)
    : QObject(parent)
{
    init();
}

QBatteryInfoPrivate::QBatteryInfoPrivate(int, QBatteryInfo *parent)
    : QObject(parent)
{
    init();
}

#define PROP_CONNECTED(parent, name)                \
    std::make_pair(QString(QS_("Battery." #name)),  \
                   &QBatteryInfoPrivate::on##name)

#define PROP_DISCONNECTED(parent, name)             \
    std::make_pair(QString(QS_("Battery." #name)),  \
                   (PropertyFn)nullptr)

enum class Prop {
    ChargePercentage = 0,
    Level,
    Energy,
    EnergyFull,
    ChargingState,
    TimeUntilFull,
    Current,
    Voltage,
    Temperature,
    ChargerType,
    Last_ = ChargerType
};

void QBatteryInfoPrivate::init()
{
    typedef void (QBatteryInfoPrivate::*PropertyFn)(void);

    // NB! There is no static check that enum Prop members correspond
    // to the property_info members, so it still should be checked
    // manually
    static const std::pair<QString, PropertyFn> property_info[] = {
        PROP_CONNECTED(parent, ChargePercentage),
        PROP_CONNECTED(parent, Level),
        PROP_CONNECTED(parent, Energy),
        PROP_DISCONNECTED(parent, EnergyFull),
        PROP_CONNECTED(parent, ChargingState),
        PROP_CONNECTED(parent, TimeUntilFull),
        PROP_CONNECTED(parent, Current),
        PROP_CONNECTED(parent, Voltage),
        PROP_CONNECTED(parent, Temperature),
        PROP_CONNECTED(parent, ChargerType)
    };

    static const auto expected_size = static_cast<size_t>(Prop::Last_) + 1;
    static_assert(sizeof(property_info) / sizeof(property_info[0]) == expected_size,
                  "Check array size");

    for (auto const &info : property_info) {
        auto const &name = info.first;
        auto target = info.second;

        auto property = new ContextProperty(name);
        properties_.push_back(property);
        if (target)
            connect(property, &ContextProperty::valueChanged, this, target);
    }
}

QVariant QBatteryInfoPrivate::value(Prop id) const
{
    return properties_[static_cast<size_t>(id)]->value();
}

void QBatteryInfoPrivate::onChargePercentage()
{
    emit remainingCapacityChanged(remainingCapacity());
}

void QBatteryInfoPrivate::onLevel()
{
    emit levelStatusChanged(levelStatus());
    emit validChanged(isValid());
}

void QBatteryInfoPrivate::onEnergy()
{
    emit remainingCapacityChanged(remainingCapacity());
}

void QBatteryInfoPrivate::onChargingState()
{
    emit chargingStateChanged(chargingState());
    emit validChanged(isValid());
}

void QBatteryInfoPrivate::onTimeUntilFull()
{
    emit remainingChargingTimeChanged(remainingChargingTime());
}

void QBatteryInfoPrivate::onCurrent()
{
    emit currentFlowChanged(currentFlow());
}

void QBatteryInfoPrivate::onVoltage()
{
    emit voltageChanged(voltage());
}

void QBatteryInfoPrivate::onTemperature()
{
    emit temperatureChanged(temperature());
}

void QBatteryInfoPrivate::onChargerType()
{
    emit chargerTypeChanged(chargerType());
}

int QBatteryInfoPrivate::batteryCount() const
{
    // only one battery is supported now
    return 1;
}

int QBatteryInfoPrivate::batteryIndex() const
{
    // only one battery is supported now
    return 0;
}

void QBatteryInfoPrivate::setBatteryIndex(int)
{
    // only one battery is supported now
}

int QBatteryInfoPrivate::currentFlow() const
{
    return value(Prop::Current).toInt(); // TODO check units
}

int QBatteryInfoPrivate::maximumCapacity() const
{
    return value(Prop::EnergyFull).toInt();
}

int QBatteryInfoPrivate::remainingCapacity() const
{
    return value(Prop::Energy).toInt();
}

int QBatteryInfoPrivate::remainingChargingTime() const
{
    return value(Prop::TimeUntilFull).toInt();
}

int QBatteryInfoPrivate::voltage() const
{
    return value(Prop::Voltage).toInt();
}

QBatteryInfo::ChargerType QBatteryInfoPrivate::chargerType() const
{
    auto name = value(Prop::ChargerType).toString();
    return chargerTypeFromName(name);
}

QBatteryInfo::ChargingState QBatteryInfoPrivate::chargingState() const
{
    return chargingStateFromName(value(Prop::ChargingState).toString());
}

QBatteryInfo::LevelStatus QBatteryInfoPrivate::levelStatus() const
{
    auto level = value(Prop::Level).toString();
    auto state = value(Prop::ChargingState).toString();
    return (level == QS_("empty")
            ? QBatteryInfo::LevelEmpty
            : (level == QS_("low")
               ? QBatteryInfo::LevelLow
               : (state == QS_("idle")
                  ? QBatteryInfo::LevelFull
                  : QBatteryInfo::LevelOk)));
}

QBatteryInfo::Health QBatteryInfoPrivate::health() const
{
    return QBatteryInfo::HealthUnknown;
}

bool QBatteryInfoPrivate::isValid() const
{
    return chargingState() != QBatteryInfo::UnknownChargingState;
}

float QBatteryInfoPrivate::temperature() const
{
    // oC
    return value(Prop::Temperature).toDouble() / 10;
}

int QBatteryInfoPrivate::level() const
{
    return value(Prop::ChargePercentage).toInt();
}

int QBatteryInfoPrivate::cycleCount() const
{
    return 1; // not exposed now
}

QT_END_NAMESPACE
