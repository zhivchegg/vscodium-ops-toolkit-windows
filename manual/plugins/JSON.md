# JSON

VSCodium имеет встроенную поддержку JSON: подсветку синтаксиса, форматирование, валидацию и работу со схемами. Никакой дополнительный плагин не требуется.

## Что проверить при инциденте

1. Файл валиден как JSON? Есть ли лишние запятые или незакрытые скобки?
2. Соответствует ли структура ожидаемой схеме?
3. Правильная ли кодировка файла (UTF-8 без BOM)?
4. Не слишком ли большой файл для быстрой обработки?

## Валидация и подсветка ошибок

VSCodium автоматически проверяет JSON при открытии файла `.json`. Ошибки показываются:
- красным волнистым подчёркиванием
- во вкладке **Problems** (`Ctrl+Shift+M`)

Типичные ошибки:

| Ошибка | Пример | Исправление |
|---|---|---|
| Лишняя запятая | `{ "a": 1, }` | Убрать последнюю запятую |
| Незакрытая скобка | `{ "a": 1` | Добавить `}` |
| Неправильный тип | `"count": "10"` | Использовать число `10` |
| Недопустимый escape | `"path": "C:\Users"` | `\\` для обратного слеша |

## Форматирование JSON

```bash
# В редакторе: открыть файл и нажать
Shift + Alt + F

# Или через палитру команд
Ctrl + Shift + P → Format Document
```

В терминале (MSYS2 Bash):

```bash
# Красивый вывод
jq '.' app.json > app-formatted.json

# Минификация
jq -c '.' app.json > app-minified.json

# Сортировка ключей
jq -S '.' app.json > app-sorted.json
```

## Преобразование в YAML

```bash
python -c "import json, yaml, sys; json.dump(json.load(sys.stdin), sys.stdout)" < file.yaml > file.json
```

Обратное преобразование:

```bash
python -c "import json, yaml, sys; yaml.safe_dump(json.load(sys.stdin), sys.stdout, allow_unicode=True)" < file.json > file.yaml
```

## Проверка JSON в терминале

```bash
# jq — если вернул пустой вывод без ошибок, JSON валиден
jq '.' app.json

# Python
python -m json.tool app.json

# Python строгая проверка
python -c "import json; json.load(open('app.json'))"
```

## JSON-схемы

VSCodium умеет валидировать JSON по схеме. Если в файле указана схема через `$schema`, проверка работает автоматически:

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "name": "server-01",
    "port": 8080
}
```

Для привязки схемы к файлу в `settings.json`:

```json
{
    "json.schemas": [
        {
            "fileMatch": ["/*.config.json"],
            "url": "./schemas/config.schema.json"
        }
    ]
}
```

## Навигация по большому JSON

- `Ctrl+Shift+O` — структура символов (JSON keys).
- `Ctrl+Shift+M` — список ошибок и предупреждений.
- Свернуть/развернуть блок: щелчок по стрелке в левом поле.

## Практический пример: разбор ответа API

```bash
# Получить ответ и отформатировать
curl -s http://localhost:8080/health | jq '.'

# Извлечь конкретное поле
curl -s http://localhost:8080/health | jq '.status'

# Найти ошибки в JSON-логах
jq 'select(.level == "ERROR")' app.ndjson

# Подсчитать события по уровню
jq -s 'group_by(.level) | map({level: .[0].level, count: length})' app.ndjson
```

## Подводные камни

- JSON не поддерживает комментарии (`//` и `/* */`). Для конфигов с комментариями используйте YAML.
- Числа в JSON ограничены 53 битами точности. Для больших чисел используйте строки.
- `undefined` — это не JSON, используйте `null`.
- При копировании из Windows-консоли могут появиться лишние BOM — сохраняйте файлы как UTF-8.
- Для сортировки и слияния JSON-файлов удобнее использовать `jq`, чем ручное редактирование.
