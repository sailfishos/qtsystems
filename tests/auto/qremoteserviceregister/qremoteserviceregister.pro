load(qttest_p4)

QT = core serviceframework

SOURCES += tst_qremoteserviceregister.cpp
HEADERS += service.h

symbian {
    TARGET.CAPABILITY = ALL -TCB
}

symbian* {
    addFiles.sources = testdata/*
    addFiles.path = xmldata
    DEPLOYMENT += addFiles
}
