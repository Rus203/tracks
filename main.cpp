#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QPixmap>
#include <QByteArray>
#include <QBuffer>

#include "src/trackmanager.h"

static void setAppIcon(QGuiApplication &app)
{
    static const char *b64 =
    "AAABAAEAEBAAAAAAIAC2AwAAFgAAAIlQTkcNChoKAAAADUlIRFIAAAAQAAAAEAgGAAAAH/P/YQAA"
    "A31JREFUeJyVk39MlHUcx9+f7/McPMfxPHccOw9BUS84EltZGmS43bRw0o/N/rjCmRlswVbWxhos"
    "6cearmXOGsza2qS0FrRRokHNaJUUpinIj1TUNOY8cQcH3NFxv+95Pv3B3Pi319+v93vvf97AAoT/"
    "j7gbJAAMeCXNPtJEkrQZGcosM4vFtizLaaSTOXoyPp4i095oYMwPgAiAQGmprAX0s6Tlqlxe1cqK"
    "FmNDFyDBkgTEE0mRmJoWyFKSjvFzXvbfqsiUsX5i4soNGYCh+VONsOXmJlv6nlWatuyjcPAh3WCA"
    "QLrOUGWR/nT/25d9oejcO2pFC/irCZPv/CedXlQBADRHSZ+let8rthLPL2bNxSZ1FVudpZyz9D5W"
    "tFW87vHqeWbu9F0dO/dR1crAQOMD365zr74NVFpkAKAM85Ss5sQS05PlDz+yfjrP6Yic7D21gkhA"
    "EQaPbazN2nVmfsMXfdvVhk32m8jOy/v1iQHH/KbptQsFBKSTUclszox89/nBUVvB8nCF56kbw/39"
    "j2qebUrowUpj6ak9eUhHL841/33QAkS0ozvrlNGeDwUAGLJMUmAmFSsql5tvW4tb/5p1XXut3R67"
    "39Md9u4hRNKXdl5s7YLz3jgDcQBSwubygylnYUEwrRuOsCavqTYdvibs6Y69zaZtL9fvPnJsrSub"
    "rrz3WU93x5nYhaaCwRO247VemFcG5YG2HUkS9QAzOQ89Peg+WzPrGmg0nF++26sCbruqvsDMHczc"
    "23bgjQ0Q9jc3lpYaP2138q2G5eOvetyXgDKNCvp3fJBvd+xqv6fx/T9DQ3n7/d+8NNlyvSfaGXh+"
    "6zOer1e7i0OHPm4zC0iVcWQUJlMG8+baOgz/+FjhnfNvyQTjuTrLlvbizHx/sTPfd1r4SroKJ1/M"
    "5KD+w8nfvN3Hf46qVqudWUcWp2FRSJeK8oP6hdmSiNDigglDx/49/SQAnkoFncPBq+V0PQImXcpW"
    "FMVqVe2sJ0GGAYOk+VRZ1euJ309s1SNhnilzTVHRUI0jkUh+X5C1pDAWjdgnA8Zg5Kj7MJnC2WBh"
    "gIjBTCBiY8WaSam/qxL/jNQQi/JQ4PIoAYDX65X6GlCZPuCrN/6IL2ObdhOAvOhLBBIpikeWIRrW"
    "QWL3XGBsBIAgMAgEvmtanK4lcmgmixLEiwrAYJLNWnIm5ruz6M7Gf0p0igjBOon0AAAAAElFTkSu"
    "QmCC";

    QByteArray bytes = QByteArray::fromBase64(b64);
    QPixmap px;
    px.loadFromData(bytes, "ICO");
    app.setWindowIcon(QIcon(px));
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("TrackViewer");
    app.setOrganizationName("TrackViewer");

    setAppIcon(app);

    TrackManager manager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("trackManager", &manager);
    engine.load(QUrl("qrc:/qml/main.qml"));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
