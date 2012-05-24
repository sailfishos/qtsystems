%define _qtmodule_snapshot_version 5~5.0.0~alpha1
Name:       qt5-qtsystems
Summary:    Qt System modules
Version:    %{_qtmodule_snapshot_version}
Release:    1%{?dist}
Group:      System/Libraries
License:    LGPLv2.1 with exception or GPLv3
URL:        http://qt.nokia.com
Source0:    %{name}-%{version}.tar.gz
Patch0:     disable_test_examples_install.patch
BuildRequires:  qt5-qtcore-devel
BuildRequires:  qt5-qtgui-devel
BuildRequires:  qt5-qtnetwork-devel
BuildRequires:  qt5-qtsql-devel
BuildRequires:  qt5-qtdbus-devel
BuildRequires:  qt5-qtxml-devel
BuildRequires:  qt5-qttest-devel
BuildRequires:  qt5-qtopengl-devel
BuildRequires:  qt5-qtqml-devel
BuildRequires:  qt5-qtqml-qtquick-devel
BuildRequires:  qt5-qmake
BuildRequires:  fdupes

%description
Qt is a cross-platform application and UI framework. Using Qt, you can
write web-enabled applications once and deploy them across desktop,
mobile and embedded systems without rewriting the source code.
.
This package contains the Qt system modules


%package -n qt5-qtsysteminfo
Summary:    Qt system info
Group:      System/Libraries
Requires(post):     /sbin/ldconfig
Requires(postun):   /sbin/ldconfig

%description -n qt5-qtsysteminfo
Qt is a cross-platform application and UI framework. Using Qt, you can
write web-enabled applications once and deploy them across desktop,
mobile and embedded systems without rewriting the source code.
.
This package contains the Qt SystemInfo module


%package -n qt5-qtsysteminfo-devel
Summary:    Qt system info - development files
Group:      Development/Libraries
Requires:   qt5-qtsysteminfo = %{version}-%{release}

%description -n qt5-qtsysteminfo-devel
Qt is a cross-platform application and UI framework. Using Qt, you can
write web-enabled applications once and deploy them across desktop,
mobile and embedded systems without rewriting the source code.
.
This package contains the Qt SystemInfo development files


%package -n qt5-qtqml-systeminfo
Summary:    Qt system info import for QtQml
Group:      System/Libraries
Requires:   qt5-qtqml

%description -n qt5-qtqml-systeminfo
This package contains the system info import for QtQml


%package -n qt5-qtserviceframework
Summary:    Qt Service Framework
Group:      System/Libraries
Requires(post):     /sbin/ldconfig
Requires(postun):   /sbin/ldconfig

%description -n qt5-qtserviceframework
Qt is a cross-platform application and UI framework. Using Qt, you can
write web-enabled applications once and deploy them across desktop,
mobile and embedded systems without rewriting the source code.
.
This package contains the Qt Service Framework module

%package -n qt5-qtserviceframework-devel
Summary:    Qt Service Framework - development files
Group:      Development/Libraries
Requires:   qt5-qtserviceframework = %{version}-%{release}

%description -n qt5-qtserviceframework-devel
Qt is a cross-platform application and UI framework. Using Qt, you can
write web-enabled applications once and deploy them across desktop,
mobile and embedded systems without rewriting the source code.
.
This package contains the Qt Service Framework development files


%package -n qt5-qtqml-serviceframework
Summary:    Qt Service Framework import for QtQml
Group:      System/Libraries
Requires:   qt5-qtqml

%description -n qt5-qtqml-serviceframework
This package contains the Service Framework import for QtQml



%package -n qt5-qtpublishsubscribe
Summary:    Qt PublishSubscribe module
Group:      System/Libraries
Requires(post):     /sbin/ldconfig
Requires(postun):   /sbin/ldconfig

%description -n qt5-qtpublishsubscribe
Qt is a cross-platform application and UI framework. Using Qt, you can
write web-enabled applications once and deploy them across desktop,
mobile and embedded systems without rewriting the source code.
.
This package contains the Qt PublishSubscribe module

%package -n qt5-qtpublishsubscribe-devel
Summary:    Qt PublishSubscribe - development files
Group:      Development/Libraries
Requires:   qt5-qtpublishsubscribe = %{version}-%{release}

%description -n qt5-qtpublishsubscribe-devel
Qt is a cross-platform application and UI framework. Using Qt, you can
write web-enabled applications once and deploy them across desktop,
mobile and embedded systems without rewriting the source code.
.
This package contains the Qt PublishSubscribe development files


%package -n qt5-qtqml-publishsubscribe
Summary:    Qt PublishSubscribe import for QtQml
Group:      System/Libraries
Requires:   qt5-qtqml

%description -n qt5-qtqml-publishsubscribe
This package contains the PublishSuvbscribe import for QtQml




#### Build section

%prep
%setup -q -n %{name}
%patch0 -p1


%build
export QTDIR=/usr/share/qt5
qmake
make %{?_smp_flags}

%install
rm -rf %{buildroot}
%qmake_install
# Remove unneeded .la files
rm -f %{buildroot}/%{_libdir}/*.la
%fdupes %{buildroot}/%{_includedir}




#### Pre/Post section

%post -n qt5-qtsysteminfo
/sbin/ldconfig
%postun -n qt5-qtsysteminfo
/sbin/ldconfig

%post -n qt5-qtserviceframework
/sbin/ldconfig
%postun -n qt5-qtserviceframework
/sbin/ldconfig

%post -n qt5-qtpublishsubscribe
/sbin/ldconfig
%postun -n qt5-qtpublishsubscribe
/sbin/ldconfig



#### File section


%files -n qt5-qtsysteminfo
%defattr(-,root,root,-)
%{_libdir}/libQtSystemInfo.so.5
%{_libdir}/libQtSystemInfo.so.5.*

%files -n qt5-qtsysteminfo-devel
%defattr(-,root,root,-)
%{_libdir}/libQtSystemInfo.so
%{_libdir}/libQtSystemInfo.prl
%{_libdir}/pkgconfig/QtSystemInfo.pc
%{_includedir}/qt5/Qt/QtSystemInfo
%{_includedir}/qt5/Qt/qtsysteminfoversion.h
%{_includedir}/qt5/Qt/qsysteminfoglobal.h
%{_includedir}/qt5/Qt/q*info.h
%{_includedir}/qt5/Qt/qdeviceprofile.h
%{_includedir}/qt5/Qt/qscreensaver.h
%{_includedir}/qt5/QtSystemInfo/
%{_datadir}/qt5/mkspecs/modules/qt_systeminfo.pri
%{_libdir}/cmake/Qt5SystemInfo/

%files -n qt5-qtqml-systeminfo
%defattr(-,root,root,-)
%{_libdir}/qt5/imports/QtSystemInfo/

%files -n qt5-qtserviceframework
%defattr(-,root,root,-)
%{_bindir}/servicefw
%{_libdir}/libQtServiceFramework.so.5
%{_libdir}/libQtServiceFramework.so.5.*

%files -n qt5-qtserviceframework-devel
%defattr(-,root,root,-)
%{_libdir}/libQtServiceFramework.so
%{_libdir}/libQtServiceFramework.prl
%{_libdir}/pkgconfig/QtServiceFramework.pc
%{_includedir}/qt5/Qt/QtServiceFramework
%{_includedir}/qt5/Qt/qtserviceframeworkversion.h
%{_includedir}/qt5/Qt/qremoteservice*.h
%{_includedir}/qt5/Qt/qservice*.h
%{_includedir}/qt5/QtServiceFramework/
%{_datadir}/qt5/mkspecs/modules/qt_serviceframework.pri
%{_libdir}/cmake/Qt5ServiceFramework/

%files -n qt5-qtqml-serviceframework
%defattr(-,root,root,-)
%{_libdir}/qt5/imports/QtServiceFramework/




%files -n qt5-qtpublishsubscribe
%defattr(-,root,root,-)
%{_libdir}/libQtPublishSubscribe.so.5
%{_libdir}/libQtPublishSubscribe.so.5.*

%files -n qt5-qtpublishsubscribe-devel
%defattr(-,root,root,-)
%{_libdir}/libQtPublishSubscribe.so
%{_libdir}/libQtPublishSubscribe.prl
%{_libdir}/pkgconfig/QtPublishSubscribe.pc
%{_includedir}/qt5/Qt/QtPublishSubscribe
%{_includedir}/qt5/Qt/qtpublishsubscribe*.h
%{_includedir}/qt5/Qt/qpublishsubscribe*.h
%{_includedir}/qt5/Qt/qvalue*.h
%{_includedir}/qt5/QtPublishSubscribe/
%{_datadir}/qt5/mkspecs/modules/qt_publishsubscribe.pri
%{_libdir}/cmake/Qt5PublishSubscribe/

%files -n qt5-qtqml-publishsubscribe
%defattr(-,root,root,-)
%{_libdir}/qt5/imports/QtPublishSubscribe/


#### No changelog section, separate $pkg.changes contains the history
