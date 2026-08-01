# Python

Работа с Python в VSCodium.

## Настройка интерпретатора

1. Запустите `configure-runtime.cmd`.
2. В секции Python нажмите `Browse...` и выберите `python.exe`.
3. Нажмите `Test` — должна появиться версия Python.
4. Нажмите `Save`.
5. Перезапустите VSCodium через `start-vscodium.cmd`.

Проверка в терминале:

```bash
python --version
which python
```

## Запуск скрипта

Откройте `.py` файл и нажмите `F5`, или в терминале:

```bash
python script.py
python script.py arg1 arg2
```

## Выбор интерпретатора вручную

`Ctrl + Shift + P` → `Python: Select Interpreter`.

## Форматирование и линтинг

- `Shift + Alt + F` — форматирование.
- Панель Problems (`Ctrl + Shift + M`) — ошибки и предупреждения.

## Пример скрипта

```python
#!/usr/bin/env python3
import json
import sys

log_file = sys.argv[1] if len(sys.argv) > 1 else "app.log"

errors = []
with open(log_file, "r", encoding="utf-8") as f:
    for line in f:
        data = json.loads(line)
        if data.get("level") in ("ERROR", "FATAL"):
            errors.append(data)

print(f"Found {len(errors)} errors")
for e in errors[:10]:
    print(f"- {e.get('timestamp')} {e.get('message')}")
```

Запуск:

```bash
python analyze_log.py app.log
```

## Работа с uv

`uv` доступен в терминале:

```bash
# Создать виртуальное окружение
uv venv .venv

# Активировать
source .venv/bin/activate

# Установить пакет
uv pip install requests

# Установить из requirements.txt
uv pip install -r requirements.txt

# Запустить скрипт
uv run script.py
```
