#pragma once

#include <QString>
#include <QVector>
#include <QStringList>

class CsvReader
{
public:
    static QVector<QStringList> readFile(const QString &filePath,
                                         QChar separator = QLatin1Char(','));
private:
    static QStringList parseLine(const QString &line, QChar separator);
};
