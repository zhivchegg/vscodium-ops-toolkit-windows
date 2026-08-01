# gron

Преобразование JSON в плоский вид, удобный для grep и diff.

## Основные примеры

```bash
# Плоское представление JSON
gron app.json

# Поиск по плоскому виду
gron app.json | grep "level"

# Поиск по значению
gron app.json | grep '"ERROR"'
```

## Работа с URL

```bash
# gron может загрузить JSON по URL
gron https://api.example.com/status
```

## Преобразование обратно

```bash
# Изменить плоский вид и собрать JSON
gron --ungron modified.gron > app.json
```

## Сравнение JSON

```bash
# Найти различия между двумя JSON-файлами
gron a.json > a.gron
gron b.json > b.gron
diff a.gron b.gron
```

## Комбинация с jq

```bash
# gron для поиска пути, jq для извлечения
gron app.json | grep "\.level"
jq '.. | objects | .level' app.json
```
