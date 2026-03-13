#include "csvreader.h"

#include <QFile>
#include <QTextStream>

QVector<QStringList> CsvReader::readFile(const QString &filePath, QChar separator)
{
    QVector<QStringList> result;

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return result;

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);

    while (!in.atEnd()) {
        const QString line = in.readLine().trimmed();
        if (!line.isEmpty())
            result.append(parseLine(line, separator));
    }

    return result;
}

QStringList CsvReader::parseLine(const QString &line, QChar separator)
{
    QStringList fields;
    QString current;
    bool inQuotes = false;

    for (int i = 0; i < line.length(); ++i) {
        const QChar ch = line[i];
        if (inQuotes) {
            if (ch == QLatin1Char('"')) {
                if (i + 1 < line.length() && line[i + 1] == QLatin1Char('"')) {
                    current += QLatin1Char('"');
                    ++i;
                } else {
                    inQuotes = false;
                }
            } else {
                current += ch;
            }
        } else {
            if (ch == QLatin1Char('"'))
                inQuotes = true;
            else if (ch == separator) {
                fields.append(current.trimmed());
                current.clear();
            } else {
                current += ch;
            }
        }
    }

    fields.append(current.trimmed());
    return fields;
}
