# grep

Поиск текста по файлам и потокам.

## Основные примеры

```bash
# Простой поиск
grep "error" app.log

# Без учёта регистра
grep -i "error" app.log

# Регулярное выражение
grep -E "error|fatal|exception" app.log

# Инвертировать поиск (исключить)
grep -v "INFO" app.log

# Количество вхождений
grep -c "ERROR" app.log

# Номера строк
grep -n "ERROR" app.log

# Рекурсивный поиск
grep -r "timeout" /var/log/

# Поиск с контекстом
grep -C 3 "ERROR" app.log
```

## Комбинации

```bash
# Поиск ошибок и сортировка по частоте
grep -oE "ERROR [^ ]+" app.log | sort | uniq -c | sort -rn

# Из файла в поток
err < app.log
warn < app.log
```

## Алиасы в сборке

```bash
alias err='grep -iE "error|fail|exception|fatal"'
alias warn='grep -iE "warn"'
alias info='grep -iE "info"'
```
