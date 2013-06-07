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

#include "qdeviceinfo_mac_p.h"

#include <QDebug>
#include <QSettings>
#include <QCryptographicHash>
#include <QtCore/private/qcore_mac_p.h>

#include <CoreLocation/CLLocation.h>
#include <CoreLocation/CLLocationManager.h>
#include <ScreenSaver/ScreenSaverDefaults.h>
#include <CoreWLAN/CWInterface.h>
#include <CoreWLAN/CWGlobals.h>
#include <CoreServices/CoreServices.h>
#include <CoreFoundation/CFNotificationCenter.h>
#include <IOBluetooth/IOBluetooth.h>
#if defined(slots)
#undef slots
#endif
#include <QTKit/QTKit.h>
#include <IOKit/pwr_mgt/IOPM.h>
#include <IOKit/pwr_mgt/IOPMLib.h>

#include <IOKit/IOKitLib.h>
#include <CoreFoundation/CFDictionary.h>

#include <sys/types.h>
#include <sys/sysctl.h>

bool hasIOServiceMatching(const QString &classstr)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    io_iterator_t ioIterator = NULL;
    IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceNameMatching(classstr.toLatin1()), &ioIterator);
    if (ioIterator) {
        [pool drain];
        return true;
    }
    [pool drain];
    return false;
}


QT_BEGIN_NAMESPACE

QDeviceInfoPrivate::QDeviceInfoPrivate(QDeviceInfo *parent)
    : QObject(parent)
    , q_ptr(parent)
{
}

bool QDeviceInfoPrivate::hasFeature(QDeviceInfo::Feature feature)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    bool featureSupported = false;
    switch (feature) {
    case QDeviceInfo::BluetoothFeature:
        {
            IOBluetoothHostController* controller = [IOBluetoothHostController defaultController];
            if (controller != NULL) {
                featureSupported = true;
            }
        }
        break;
    case QDeviceInfo::CameraFeature:
        {
           NSArray * videoDevices;
           videoDevices = [[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] arrayByAddingObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]];
           if ([videoDevices count] > 0) {
               featureSupported = true;
           }
        }
        break;
    case QDeviceInfo::FmRadioFeature:
    case QDeviceInfo::FmTransmitterFeature:
        break;
    case QDeviceInfo::InfraredFeature:
        {
            if (hasIOServiceMatching("AppleIRController")) {
                featureSupported = true;
            }
        }
        break;
    case QDeviceInfo::LedFeature:
        {
//kHIDPage_LEDs
        }
        break;
    case QDeviceInfo::MemoryCardFeature:
        {
// IOSCSIPeripheralDeviceType0E
            if (hasIOServiceMatching("IOUSBMassStorageClass")) {
                featureSupported = true;
            }
        }
        break;
    case QDeviceInfo::UsbFeature:
        {
            if (hasIOServiceMatching("AppleUSBOHCI")) {
                featureSupported = true;
            }
            if (hasIOServiceMatching("AppleUSBEHCI")) {
                featureSupported = true;
            }
        }
        break;
    case QDeviceInfo::VibrationFeature:
        {
        }
        break;
    case QDeviceInfo::WlanFeature:
        {
        NSArray *wifiInterfaces = [CWInterface supportedInterfaces];
        if (wifiInterfaces || wifiInterfaces.count > 0)
            featureSupported = true;
        }
        break;
    case QDeviceInfo::SimFeature:
        {
        }
        break;
    case QDeviceInfo::PositioningFeature:
        {
            if ([CLLocationManager locationServicesEnabled]) {
                featureSupported = true;
            }
        }
        break;
    case QDeviceInfo::VideoOutFeature:
        {
            ComponentDescription description = {'vout', 0, 0, 0L, 1L << 0};
            if ( ::CountComponents(&description) > 0) {
                featureSupported = true;
            }
        }
        break;
    case QDeviceInfo::HapticsFeature:
    case QDeviceInfo::NfcFeature:
        break;
    default:
        featureSupported = false;
        break;
    };
    [pool drain];
    return featureSupported;
}

int QDeviceInfoPrivate::imeiCount()
{
    return -1;
}

QDeviceInfo::LockTypeFlags QDeviceInfoPrivate::activatedLocks()
{
  // QSettings seems to not work on mac.
    // FIXME
//    // find out if auto login is being used.
//    QSettings loginSettings("/Library/Preferences/com.apple.loginwindow.plist", QSettings::NativeFormat);
//    QString autologinname = loginSettings.value("autoLoginUser").toString();

//    QSettings zwoptexList("/Library/Preferences/com.apple.screensaver.plist",QSettings::NativeFormat);
//    QStringList keys = zwoptexList.allKeys();
//    qDebug() << "keys" << keys;
//    for (int i = 0; i < keys.size(); i++) {
//        QString tempString = keys.at(i);
//        qDebug() << tempString;
//    }

//// find out if locked screensaver is used.
//    int passWordProtected = 0;
////#if defined(QT_ARCH_X86_64)  && !defined(MAC_SDK_10_6)
//    QSettings screensaverSettings("/Library/Preferences/com.apple.screensaver.plist", QSettings::NativeFormat);
//    passWordProtected = screensaverSettings.value("askForPassword").toInt();

////    ScreenSaverDefaults *ssDefaults;
////    ssDefaults = [ScreenSaverDefaults defaultsForModuleWithName:@"com.apple.screensaver"];
////    passWordProtected = [ssDefaults integerForKey:@"askForPassword"];
////#endif
//    qDebug() <<passWordProtected;
//    if (autologinname.isEmpty() || passWordProtected == 1) {
        return QDeviceInfo::UnknownLock;
//    }

//    return QDeviceInfo::NoLock;
}

QDeviceInfo::LockTypeFlags QDeviceInfoPrivate::enabledLocks()
{
    return QDeviceInfo::UnknownLock;
}

QDeviceInfo::ThermalState QDeviceInfoPrivate::thermalState()
{
    // TODO fixme
//    int value = 0;
//    int it = 0;
//    kern_return_t kr;
//    io_iterator_t hwSensors;
//    io_service_t hwSensorService;
//    CFMutableDictionaryRef sensorDict;

//    kr = IOServiceGetMatchingServices(kIOMasterPortDefault,
//                                      IOServiceNameMatching("IOHWSensor"), &hwSensors);

//    while ((hwSensorService = IOIteratorNext(hwSensors))) {
//        kr = IORegistryEntryCreateCFProperties(hwSensorService, &sensorDict, kCFAllocatorDefault, kNilOptions);
//        if (kr == KERN_SUCCESS) {
//            SInt32 currentValue;
//            CFNumberRef sensorValue;
//            CFStringRef sensorType;
//            if (CFStringCompare(sensorType, CFSTR("temperature"), 0) != kCFCompareEqualTo)
//                continue;

//            sensorValue = (const __CFNumber *)CFDictionaryGetValue((CFDictionaryRef)sensorDict,
//                                                                   CFSTR("current-value"));

//            (void)CFNumberGetValue(sensorValue, kCFNumberSInt32Type,
//                                   (void *)&currentValue);
//            value += currentValue;
//            it++;
//        }
//        CFRelease(sensorDict);
//        IOObjectRelease(hwSensorService);
//    }

//    IOObjectRelease(hwSensors);

//    qDebug() << "average value" << (value / it) / 65536;

    //    IOServiceMatching("IOHWSensor");
//    static io_connect_t dataPort = 0;

//    kern_return_t kreturn;
//    io_service_t ioService;

//    ioService = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOHWSensor"));
//    if (!ioService) {
//        qDebug() << "IOHWSensor error";
//        return QDeviceInfo::UnknownThermal;
//    }

//    qDebug() << ioService->getProperty("current-value");;

//    kreturn = IOServiceOpen(ioService, mach_task_self(), 0, &dataPort);
//    IOObjectRelease(ioService);
//    if (kreturn != KERN_SUCCESS) {
//        qDebug() << "IOServiceOpen "<< kreturn;
//        return QDeviceInfo::UnknownThermal;
//    }

//    uint64_t inputValues[1] = {0};

//    uint32_t outputCount = 1;
//    uint64_t outputValues[1];

//    kreturn = IOConnectCallScalarMethod(dataPort,1,inputValues,1,outputValues,&outputCount);
//    if (kreturn != KERN_SUCCESS) {
//        qDebug() << "keyboard error";
//        return QDeviceInfo::UnknownThermal;
//    }

//    uint32_t  getlevel = 0;
//    CFStringRef thermal_key = NULL;
//    IOReturn ret = kIOReturnError;

//    ret = IOPMGetThermalWarningLevel(&getlevel);
//        if ((kIOReturnSuccess == ret)) {
//            qDebug() << getlevel;
//        }
    return QDeviceInfo::UnknownThermal;
}

QString QDeviceInfoPrivate::imei(int)
{
    return QString();
}

QString QDeviceInfoPrivate::manufacturer()
{
    return QLatin1String("Apple"); //pretty sure we can hardcode this one
}

QString QDeviceInfoPrivate::model()
{
    char modelBuffer[256];
    QString model;
      size_t sz = sizeof(modelBuffer);
      if (0 == sysctlbyname("hw.model", modelBuffer, &sz, NULL, 0)) {
          model = QLatin1String(modelBuffer);
      }
    return  model;
}

QString QDeviceInfoPrivate::productName()
{
    char modelBuffer[256];
    QString model;
      size_t sz = sizeof(modelBuffer);
      if (0 == sysctlbyname("hw.model", modelBuffer, &sz, NULL, 0)) {
          model = QLatin1String(modelBuffer);
      }
      if (model.count() > 3)
          model = model.left(model.count() - 3);
      return  model;
}

QString QDeviceInfoPrivate::uniqueDeviceID()
{
    CFStringRef uuidKey = CFSTR(kIOPlatformUUIDKey);
    io_service_t ioService = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                         IOServiceMatching("IOPlatformExpertDevice"));
    QCryptographicHash hash(QCryptographicHash::Sha1);
    if (ioService) {
        CFTypeRef cfStringKey = IORegistryEntryCreateCFProperty(ioService, uuidKey, kCFAllocatorDefault, 0);

        hash.addData(QCFString::toQString((const __CFString*)cfStringKey).toLocal8Bit());
        return QString::fromLatin1(hash.result().toHex());
    }
    hash.addData(QString::number(gethostid()).toLocal8Bit());
    return QString::fromLatin1(hash.result().toHex());
}

QString QDeviceInfoPrivate::version(QDeviceInfo::Version type)
{
    switch (type) {
    case QDeviceInfo::Os:
        {
//        QSettings versionSettings("/System/Library/CoreServices/SystemVersion.plist", QSettings::NativeFormat);
//        return versionSettings.value("ProductVersion").toString();
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            QString ver = QCFString::toQString([[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"]);
            [pool drain];
            return ver;
        }
        break;
    case QDeviceInfo::Firmware:
        {
        char firmwareBuffer[256];
        QString firmware;
          size_t sz = sizeof(firmwareBuffer);
          if (0 == sysctlbyname("kern.version", firmwareBuffer, &sz, NULL, 0)) {
              firmware = QLatin1String(firmwareBuffer);
          }
          return firmware;
        }
        break;
    };
    return QString();
}

    QT_END_NAMESPACE
