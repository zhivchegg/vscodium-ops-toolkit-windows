# gron

Преобразование JSON в плоский вид, удобный для grep, diff и поиска путей.

## Что проверить при инциденте

1. В каком поле JSON содержится ошибка?
2. Изменилась ли структура JSON между двумя версиями?
3. Какой путь соответствует нужному значению?
4. Пропало ли поле в новой версии ответа API?

## Основные примеры

```bash
# Плоское представление JSON
gron app.json

# Монохромный вывод (без ANSI-цветов)
gron --json app.json

# Поиск поля по имени
gron app.json | grep "level"

# Поиск по значению
gron app.json | grep '"ERROR"'

# Найти все пути к полям, содержащим URL
gron app.json | grep "http"
```

## Сравнение JSON

```bash
# Преобразовать оба файла
gron a.json > a.gron
gron b.json > b.gron

# Найти различия
diff a.gron b.gron

# Или сразу
gron a.json | diff - <(gron b.json)

# Различия через git diff
gron a.json > a.gron && gron b.json > b.gron && git diff --no-index a.gron b.gron
```

## Преобразование обратно

```bash
# Изменить плоский вид и собрать JSON
gron --ungron modified.gron > app.json
```

## Комбинация с jq

```bash
# gron показывает путь, jq извлекает значение
gron app.json | grep "\.status"
jq '.status' app.json
```

## Практический пример: поиск неизвестных полей

```bash
# Увидеть все поля верхнего уровня
gron app.json | grep '^json = {};\|^json\.[^.]* ='

# Найти все поля, содержащие дату
gron app.json | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}'

# Проверить, изменилось ли поле между версиями
gron v1.json | grep "\.apiVersion"
gron v2.json | grep "\.apiVersion"
```

## Подводные камни

- gron не умеет работать с NDJSON (по одному JSON на строку) напрямую — сначала разделите файл.
- Для очень больших JSON (>100 МБ) gron может быть медленным — используйте jq.
- Пути в gron начинаются с `json.` — учитывайте это при grep.
- `gron --ungron` требует корректного плоского синтаксиса — случайное изменение может сломать структуру.
