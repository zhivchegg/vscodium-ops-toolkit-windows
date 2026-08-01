# jq

Обработка и фильтрация JSON из командной строки.

## Основные примеры

```bash
# Красивый вывод JSON
jq '.' app.json

# Извлечь поле
jq '.name' app.json

# Извлечь вложенное поле
jq '.spec.replicas' deployment.json

# Массив элементов
jq '.items[].name' app.json

# Длина массива
jq '.items | length' app.json
```

## Фильтры

```bash
# Выбрать элементы по условию
jq '.items[] | select(.status == "ERROR")' app.json

# Выбрать по наличию поля
jq '.items[] | select(.message)' app.json

# Сравнение чисел
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
```

## Работа с потоками

```bash
# Обработать каждую строку NDJSON
jq -c '.level' app.ndjson

# Группировать логи по уровню
jq -s 'group_by(.level) | map({level: .[0].level, count: length})' app.ndjson
```
