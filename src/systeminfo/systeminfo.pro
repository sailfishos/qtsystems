TARGET = QtSystemInfo
QPRO_PWD = $PWD

QT = core network
PUBLIC_HEADERS = qsysteminfoglobal.h \
                 qdeviceinfo.h \
                 qscreensaver.h \
                 qbatteryinfo.h \
                 qnetworkinfo.h
#                 qstorageinfo.h \

SOURCES += qdeviceinfo.cpp \
           qscreensaver.cpp \
           qbatteryinfo.cpp \
           qnetworkinfo.cpp
#           qstorageinfo.cpp \

win32: !simulator: {
    contains(CONFIG, release) {
       CONFIG -= console
    }

    win32-msvc*: {
        LIBS += -lUser32 -lGdi32 -lPowrProf -lBthprops -lWs2_32 -lVfw32 -lSetupapi -lIphlpapi -lOle32 -lWbemuuid
    }

    win32-g++*: {
        LIBS += -luser32 -lgdi32 -lpowrprof -lbthprops -lws2_32 -lmsvfw32 -lavicap32 -luuid
    }

    PRIVATE_HEADERS += windows/qscreensaver_win_p.h \
                       windows/qdeviceinfo_win_p.h \
                       windows/qstorageinfo_win_p.h \
                       windows/qbatteryinfo_win_p.h \
                       windows/qnetworkinfo_win_p.h \
                       windows/qwmihelper_win_p.h \
                       windows/qsysteminfoglobal_p.h

    SOURCES += windows/qscreensaver_win.cpp \
               windows/qdeviceinfo_win.cpp \
               windows/qstorageinfo_win.cpp \
               windows/qbatteryinfo_win.cpp \
               windows/qnetworkinfo_win.cpp \
               windows/qwmihelper_win.cpp

       LIBS += \
            -lOle32 \
            -lUser32 \
            -lGdi32 \
            -lIphlpapi \
            -lOleaut32 \
            -lPowrProf \
            -lSetupapi

  win32-g++: {
        LIBS += -luser32 -lgdi32
    }

}

linux-*: !simulator: {
    PRIVATE_HEADERS += linux/qdeviceinfo_linux_p.h \
                       linux/qnetworkinfo_linux_p.h \
                       linux/qscreensaver_linux_p.h
#                       linux/qstorageinfo_linux_p.h \

    SOURCES += linux/qdeviceinfo_linux.cpp \
               linux/qnetworkinfo_linux.cpp \
               linux/qscreensaver_linux.cpp
#               linux/qstorageinfo_linux.cpp \

    x11|config_x11: !contains(CONFIG,nox11option) {
        CONFIG += link_pkgconfig
        PKGCONFIG += x11
    } else: {
        DEFINES += QT_NO_X11
    }

    config_bluez: contains(CONFIG,bluez) {
        CONFIG += link_pkgconfig
        PKGCONFIG += bluez
    } else: {
        DEFINES += QT_NO_BLUEZ
    }

    qtHaveModule(dbus) {
        QT += dbus
        contains(CONFIG,ofono): {
            PRIVATE_HEADERS += linux/qofonowrapper_p.h
            SOURCES += linux/qofonowrapper.cpp
        } else {
            DEFINES += QT_NO_OFONO
        }

        config_udisks {
            QT_PRIVATE += dbus
        } else: {
            DEFINES += QT_NO_UDISKS
        }
        contains(CONFIG,upower): {
            DEFINES += QT_UPOWER
            SOURCES += linux/qdevicekitservice_linux.cpp \
                       linux/qbatteryinfo_upower.cpp
            HEADERS += linux/qdevicekitservice_linux_p.h \
                       linux/qbatteryinfo_upower_p.h
        } else {
            contains(CONFIG,statefs) {
                DEFINES += QT_STATEFS
                CONFIG += c++11 link_pkgconfig
                PKGCONFIG += contextkit-statefs
                HEADERS += linux/qbatteryinfo_statefs_p.h
                SOURCES += linux/qbatteryinfo_statefs.cpp
            } else {
                contains(CONFIG,battery_mce) {
                    DEFINES   += QT_BATTERY_MCE
                    CONFIG    += link_pkgconfig
                    PKGCONFIG += mce-qt5
                    HEADERS   += linux/qbatteryinfo_mce_p.h
                    SOURCES   += linux/qbatteryinfo_mce.cpp
                } else {
                    HEADERS += linux/qbatteryinfo_linux_p.h
                    SOURCES += linux/qbatteryinfo_linux.cpp
                }
            }
        }

        # SSU tool for Nemo Mobile, see https://github.com/nemomobile/ssu
        contains(CONFIG,ssu): {
            LIBS += -lssu
            DEFINES += QT_USE_SSU
        }

    } else {
        contains(CONFIG,statefs) {
            DEFINES += QT_STATEFS
            CONFIG += c++11 link_pkgconfig
            PKGCONFIG += contextkit-statefs
            HEADERS += linux/qbatteryinfo_statefs_p.h
            SOURCES += linux/qbatteryinfo_statefs.cpp
        } else {
            contains(CONFIG,battery_mce) {
                DEFINES   += QT_BATTERY_MCE
                CONFIG    += link_pkgconfig
                PKGCONFIG += mce-qt5
                HEADERS   += linux/qbatteryinfo_mce_p.h
                SOURCES   += linux/qbatteryinfo_mce.cpp
            } else {
                DEFINES += QT_NO_OFONO QT_NO_UDISKS
                HEADERS += linux/qbatteryinfo_linux_p.h
                SOURCES += linux/qbatteryinfo_linux.cpp
            }
        }
    }

    config_udev {
        CONFIG += link_pkgconfig
        PKGCONFIG += udev
        LIBS += -ludev
        PRIVATE_HEADERS += linux/qudevwrapper_p.h
        SOURCES += linux/qudevwrapper.cpp
    } else {
        DEFINES += QT_NO_UDEV
    }
}

macx:!simulator {
#CONFIG -= x86_64
QT += core-private
         OBJECTIVE_SOURCES += mac/qbatteryinfo_mac.mm \
                  mac/qdeviceinfo_mac.mm \
                  mac/qnetworkinfo_mac.mm \
                  mac/qscreensaver_mac.mm \
                  mac/qstorageinfo_mac.mm

         PRIVATE_HEADERS += mac/qbatteryinfo_mac_p.h \
                  mac/qdeviceinfo_mac_p.h \
                  mac/qnetworkinfo_mac_p.h \
                  mac/qscreensaver_mac_p.h \
                  mac/qstorageinfo_mac_p.h

         LIBS += -framework SystemConfiguration \
                -framework Foundation \
                -framework IOKit  \
                -framework QTKit \
                -framework CoreWLAN \
                -framework CoreLocation \
                -framework CoreFoundation \
                -framework ScreenSaver \
                -framework IOBluetooth \
                -framework CoreServices \
                -framework DiskArbitration \
                -framework ApplicationServices
}

simulator {
    QT_PRIVATE += simulator
    DEFINES += QT_SIMULATOR
    PRIVATE_HEADERS += simulator/qsysteminfodata_simulator_p.h \
                       simulator/qsysteminfobackend_simulator_p.h \
                       simulator/qsysteminfoconnection_simulator_p.h \
                       simulator/qsysteminfo_simulator_p.h


    SOURCES += simulator/qsysteminfodata_simulator.cpp \
               simulator/qsysteminfobackend_simulator.cpp \
               simulator/qsysteminfoconnection_simulator.cpp \
               simulator/qsysteminfo_simulator.cpp


    linux-*: {
        PRIVATE_HEADERS += \
                           linux/qscreensaver_linux_p.h \
#                           linux/qstorageinfo_linux_p.h

        SOURCES += \
                   linux/qscreensaver_linux.cpp \
#                   linux/qstorageinfo_linux.cpp

        x11|config_x11 {
            CONFIG += link_pkgconfig
            PKGCONFIG += x11
        } else: {
            DEFINES += QT_NO_X11
        }

        config_bluez {
            CONFIG += link_pkgconfig
            PKGCONFIG += bluez
        } else: {
            DEFINES += QT_NO_BLUEZ
        }

        qtHaveModule(dbus) {
            config_ofono: {
            QT += dbus
            PRIVATE_HEADERS += linux/qofonowrapper_p.h \
                               linux/qnetworkinfo_linux_p.h

            SOURCES += linux/qofonowrapper.cpp \
                       linux/qnetworkinfo_linux.cpp
            } else {
                DEFINES += QT_NO_OFONO
            }
            contains(config_test_udisks, yes): {
                QT_PRIVATE += dbus
            } else: {
                DEFINES += QT_NO_UDISKS
            }
        } else {
            DEFINES += QT_NO_OFONO QT_NO_UDISKS
        }

        config_udev {
            CONFIG += link_pkgconfig
            PKGCONFIG += udev
            LIBS += -ludev
            PRIVATE_HEADERS += linux/qudevwrapper_p.h
            SOURCES += linux/qudevwrapper.cpp
        } else {
            DEFINES += QT_NO_UDEV
        }

    }
}

QMAKE_DOCS = $$PWD/../../doc/config/systeminfo/qtsysteminfo.qdocconf

HEADERS += $$PUBLIC_HEADERS $$PRIVATE_HEADERS
load(qt_module)

# This must be done after loading qt_module.prf
config_bluez {
    # bluetooth.h is not standards compliant
    contains(QMAKE_CXXFLAGS, -std=c++0x) {
        QMAKE_CXXFLAGS -= -std=c++0x
        QMAKE_CXXFLAGS += -std=gnu++0x
        CONFIG -= c++11
    }
    c++11 {
        CONFIG -= c++11
        QMAKE_CXXFLAGS += -std=gnu++0x
    }
}

