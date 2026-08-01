# jq

Обработка и фильтрация JSON из командной строки.

## Что проверить при инциденте

1. Структура JSON соответствует ожидаемой?
2. Какие записи содержат ошибки?
3. Как сгруппировать события по уровню/сервису?
4. Как быстро извлечь нужные поля из большого файла?

## Основные примеры

```bash
# Красивый вывод
jq '.' app.json

# Извлечь поле
jq '.name' app.json

# Вложенное поле
jq '.spec.replicas' deployment.json

# Элементы массива
jq '.items[].name' app.json

# Длина массива
jq '.items | length' app.json
```

## Фильтрация

```bash
# Выбрать по условию
jq '.items[] | select(.status == "ERROR")' app.json

# По наличию поля
jq '.items[] | select(.message)' app.json

# Числовое сравнение
jq '.items[] | select(.code > 400)' app.json

# Комбинировать условия
jq '.items[] | select(.level == "ERROR" and .code >= 500)' app.json
```

## Преобразования

```bash
# Извлечь только нужные поля
jq '.items[] | {name: .name, status: .status}' app.json

# Объединить в массив
jq '[.items[] | {name: .name, status: .status}]' app.json

# Значения полей как массив строк
jq '[.items[].name]' app.json

# Группировка
jq 'group_by(.level) | map({level: .[0].level, count: length})' app.json
```

## Работа с NDJSON (JSON-логи)

```bash
# Обработать каждую строку
jq -c '.level' app.ndjson

# Группировка по уровню
jq -s 'group_by(.level) | map({level: .[0].level, count: length})' app.ndjson

# Подсчёт ошибок по сервису
jq -s 'map(select(.level == "ERROR")) | group_by(.service) | map({service: .[0].service, count: length})' app.ndjson
```

## Практический пример: анализ логов

```bash
# Все ошибки с временной меткой и сообщением
jq 'select(.level == "ERROR") | {timestamp, message, service}' app.ndjson

# Топ-10 самых частых сообщений об ошибках
jq -s 'map(select(.level == "ERROR")) | group_by(.message) | map({message: .[0].message, count: length}) | sort_by(-.count) | .[:10]' app.ndjson
```

## Подводные камни

- jq по умолчанию выводит красивый JSON; для компактного используйте `-c`.
- При фильтрации массива `.items[] | select(...)` выводит поток объектов, для массива оберните в `[...]`.
- Для больших файлов используйте `--stream` или `jq -c`.
- jq строго требует валидный JSON: одиночные кавычки, trailing commas не допускаются.
