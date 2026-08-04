# uv

Быстрый Python package manager и инструмент для управления окружениями.

## Что проверить при инциденте

1. Какая версия Python используется?
2. Установлены ли нужные пакеты?
3. Скрипт запускается в правильном виртуальном окружении?
4. Нет ли конфликтов зависимостей?
5. Не закончилось ли место в кеше?

## Проверка версии

```bash
uv --version
```

## Виртуальные окружения

```bash
# Создать окружение в текущей папке
uv venv .venv

# Создать с конкретной версией Python
uv venv --python 3.12 .venv

# Активировать
source .venv/bin/activate

# Деактивировать
deactivate
```

## Установка пакетов

```bash
# Один пакет
uv pip install requests

# Из requirements.txt
uv pip install -r requirements.txt

# Обновить пакет
uv pip install --upgrade requests

# Зафиксировать зависимости
uv pip freeze > requirements.txt
```

## Компиляция зависимостей

```bash
# Создать lock-файл из requirements.in
uv pip compile requirements.in -o requirements.txt

# Установить строго по lock-файлу
uv pip sync requirements.txt
```

## Запуск скриптов

```bash
# В активированном окружении
python script.py

# Без активации — uv сам подберёт окружение
uv run script.py

# Запустить с аргументами
uv run script.py arg1 arg2

# Выполнить команду из пакета
uv run --with httpie http GET https://api.example.com
```

## Установка инструментов

```bash
# Установить CLI-утилиту глобально
uv tool install httpie

# Запустить без установки
uvx http GET https://api.example.com
```

## Управление версиями Python

```bash
# Установить конкретную версию Python
uv python install 3.12

# Закрепить версию для проекта
uv python pin 3.12

# Список установленных версий
uv python list
```

## Очистка кеша

```bash
uv cache clean
```

## Практический пример: быстрый скрипт для инцидента

```bash
# Создать временное окружение и установить зависимости
uv venv /tmp/incident-venv
source /tmp/incident-venv/bin/activate
uv pip install requests rich

# Запустить скрипт
python analyze_incident.py
```

## Подводные камни

- В MSYS2 `uv run` может искать Python в неожиданных местах — проверяйте `which python`.
- `uv pip` работает только с активированным окружением или при указании `--python`.
- Для production-скриптов фиксируйте версии пакетов в `requirements.txt`.
- Если `uv` не видит установленный Python, укажите путь: `uv venv --python /path/to/python.exe`.
- `uv tool install` устанавливает инструменты изолированно — они не попадают в текущее виртуальное окружение.
