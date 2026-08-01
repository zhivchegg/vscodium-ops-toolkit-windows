# Bash IDE и shellcheck

## Bash IDE

- Автодополнение встроенных команд bash.
- Подсветка синтаксиса.
- Переход к определению функций.
- Hover-документация по командам.

## shellcheck

Анализирует скрипты и находит:
- незакрытые кавычки
- неинициализированные переменные
- уязвимости в подстановках
- устаревший синтаксис

Пример проблемы:

```bash
#!/usr/bin/env bash
name=$1
echo "Hello $name"      # OK
echo "Hello $NAME"      # shellcheck: переменная NAME не определена
rm -rf "$1"             # проверьте, что аргумент не пустой
```

## Хороший шаблон скрипта

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${1:-app.log}"
LIMIT="${2:-10}"

echo "Analyzing $LOG_FILE"
grep -iE "error|fatal|exception" "$LOG_FILE" | sort | uniq -c | sort -rn | head -n "$LIMIT"
```

## Что делает `set -euo pipefail`

- `-e` — выход при ошибке.
- `-u` — ошибка при использовании неопределённой переменной.
- `-o pipefail` — весь pipeline считается неудачным, если неудачен любой из шагов.

## Запуск shellcheck вручную

```bash
shellcheck script.sh
```
