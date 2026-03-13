#include "trackmanager.h"
#include "csvreader.h"

#include <QDir>
#include <QFileInfo>
#include <QCoreApplication>

TrackManager::TrackManager(QObject *parent)
    : QObject(parent)
    , m_tracksDir(QCoreApplication::applicationDirPath() + "/tracks")
{
    QDir dir(m_tracksDir);
    if (!dir.exists())
        dir.mkpath(".");

    scanDirectory();
}

QStringList TrackManager::trackNames() const
{
    return m_trackNames;
}

void TrackManager::scanDirectory()
{
    m_trackNames.clear();
    m_trackFiles.clear();

    QDir dir(m_tracksDir);
    dir.setNameFilters({ "*.csv" });
    dir.setFilter(QDir::Files | QDir::Readable);
    dir.setSorting(QDir::Name);

    for (const QFileInfo &fi : dir.entryInfoList()) {
        m_trackFiles << fi.absoluteFilePath();
        m_trackNames << fi.completeBaseName();
    }

    emit trackNamesChanged();
}

bool TrackManager::extractCoords(const QStringList &fields, double &lat, double &lon)
{
    for (int i = 0; i + 1 < fields.size(); ++i) {
        bool ok1 = false, ok2 = false;
        const double a = fields.at(i).toDouble(&ok1);
        const double b = fields.at(i + 1).toDouble(&ok2);

        if (ok1 && ok2 && a >= -90.0 && a <= 90.0 && b >= -180.0 && b <= 180.0) {
            lat = a;
            lon = b;
            return true;
        }
    }
    return false;
}

bool TrackManager::isTrackValid(int index) const
{
    if (index < 0 || index >= m_trackFiles.size())
        return false;

    const auto rows = CsvReader::readFile(m_trackFiles.at(index));
    if (rows.isEmpty())
        return false;

    double lat, lon;
    for (const auto &row : rows) {
        if (extractCoords(row, lat, lon))
            return true;
    }
    return false;
}

QVariantList TrackManager::getTrackCoordinates(int index) const
{
    if (index < 0 || index >= m_trackFiles.size())
        return {};

    const auto rows = CsvReader::readFile(m_trackFiles.at(index));
    if (rows.isEmpty())
        return {};

    QVariantList result;
    result.reserve(rows.size());

    for (const auto &row : rows) {
        double lat = 0.0, lon = 0.0;
        if (!extractCoords(row, lat, lon))
            continue;

        QVariantMap pt;
        pt["latitude"]  = lat;
        pt["longitude"] = lon;
        result.append(pt);
    }

    return result;
}
