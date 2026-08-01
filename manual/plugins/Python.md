# Python

Работа с Python в VSCodium. Python не включён в сборку — подключается через `configure-runtime.cmd`.

## Что проверить при инциденте

1. Выбран ли правильный интерпретатор?
2. Работает ли интерпретатор в терминале?
3. Установлены ли нужные пакеты?
4. Нет ли конфликтов между системным Python и виртуальным окружением?

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

## Выбор интерпретатора вручную

`Ctrl + Shift + P` → `Python: Select Interpreter`.

## Запуск и отладка

Откройте `.py` файл и нажмите `F5`, или в терминале:

```bash
python script.py
python script.py arg1 arg2
```

Для отладки без IDE:

```bash
python -m pdb script.py
```

## Форматирование и линтинг

- `Shift + Alt + F` — форматирование.
- Панель Problems (`Ctrl + Shift + M`) — ошибки и предупреждения.

## Работа с uv

`uv` доступен в терминале:

```bash
# Создать окружение
uv venv .venv

# Активировать
source .venv/bin/activate

# Установить пакеты
uv pip install requests
uv pip install -r requirements.txt

# Запустить скрипт в изолированном окружении
uv run script.py
```

## Практический пример: разбор JSON-логов

```python
#!/usr/bin/env python3
import json
import sys
from collections import Counter

log_file = sys.argv[1] if len(sys.argv) > 1 else "app.log"
levels = Counter()
errors = []

with open(log_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            data = json.loads(line)
        except json.JSONDecodeError as e:
            print(f"Malformed JSON: {e}", file=sys.stderr)
            continue
        level = data.get("level", "UNKNOWN")
        levels[level] += 1
        if level in ("ERROR", "FATAL"):
            errors.append(data)

print("Уровни логирования:")
for level, count in levels.most_common():
    print(f"  {level}: {count}")

print(f"\nПоследние ошибки ({len(errors)} всего):")
for e in errors[-10:]:
    print(f"- {e.get('timestamp')} {e.get('message')}")
```

## Подводные камни

- `python` может вести на Windows-версию, а не MSYS2 — проверяйте `which python`.
- Без виртуального окружения пакеты устанавливаются глобально и могут конфликтовать.
- Пути в Windows и MSYS2 различаются: `C:/Users/...` vs `/c/Users/...`.
