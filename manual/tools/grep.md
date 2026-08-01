# grep

Поиск текста по файлам и потокам. Главный инструмент для анализа логов.

## Что проверить при инциденте

1. Есть ли ошибки в логе?
2. В какое время произошла ошибка?
3. Какие ошибки повторяются чаще всего?
4. Есть ли исключения или stack trace?
5. В каких файлах встречается паттерн?

## Основные примеры

```bash
# Простой поиск
grep "error" app.log

# Без учёта регистра
grep -i "error" app.log

# Регулярное выражение
grep -E "error|fatal|exception" app.log

# Поиск целого слова
grep -w "error" app.log

# Инвертировать поиск
grep -v "INFO" app.log

# Количество вхождений
grep -c "ERROR" app.log

# Номера строк
grep -n "ERROR" app.log

# Рекурсивный поиск
grep -r "timeout" /var/log/

# Только имена файлов
grep -l "ERROR" *.log

# Поиск с контекстом
grep -C 3 "ERROR" app.log
```

## Частотный анализ ошибок

```bash
# Топ ошибок
grep -oE "ERROR [^ ]+" app.log | sort | uniq -c | sort -rn | head -20

# Типы исключений
grep -oE "[A-Za-z]+Exception" app.log | sort | uniq -c | sort -rn

# Первое и последнее вхождение
grep -n "ERROR" app.log | head -1
grep -n "ERROR" app.log | tail -1
```

## Работа с файлами, содержащими пробелы

```bash
# Нулевой разделитель для xargs
grep -rlZ "ERROR" logs/ | xargs -0 -I {} grep -H "FATAL" {}
```

## Алиасы в сборке

```bash
alias err='grep -iE "error|fail|exception|fatal"'
alias warn='grep -iE "warn"'
alias info='grep -iE "info"'
```

Пример использования:

```bash
err < app.log
warn < app.log | tail -20
```

## Практический пример: анализ инцидента

```bash
# Найти все ошибки со строками до и после
grep -n -C 5 -i "timeout" app.log > timeout_incident.log

# Ошибки за конкретный час (если дата/время в начале строки)
grep "^2024-01-15 10:" app.log | err | head -50

# Поиск по нескольким файлам с указанием имени файла
grep -H -n "ERROR" app.log app2.log

# Исключить бинарные файлы при рекурсивном поиске
grep -RI "config" /etc/
```

## Подводные камни

- `grep` по умолчанию ищет строки целиком, а не слова. Для поиска слова используйте `-w`.
- Регулярные выражения в `grep` базовые; для расширенных используйте `grep -E`.
- Бинарные файлы могут испортить вывод — используйте `-I` или `-a`.
- Для больших файлов `grep` быстрый, но если нужна сложная фильтрация, комбинируйте с `awk` или `jq`.
- `grep -r` следует по символическим ссылкам, `grep -R` — нет.
