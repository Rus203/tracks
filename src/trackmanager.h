#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>

class TrackManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList trackNames READ trackNames NOTIFY trackNamesChanged)

public:
    explicit TrackManager(QObject *parent = nullptr);

    QStringList trackNames() const;

    Q_INVOKABLE QVariantList getTrackCoordinates(int index) const;
    Q_INVOKABLE bool isTrackValid(int index) const;

signals:
    void trackNamesChanged();

private:
    void scanDirectory();
    static bool extractCoords(const QStringList &fields, double &lat, double &lon);

    QString     m_tracksDir;
    QStringList m_trackNames;
    QStringList m_trackFiles;
};
