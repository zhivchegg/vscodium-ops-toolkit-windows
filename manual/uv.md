# uv

Быстрый Python package manager и инструмент для управления окружениями.

## Установка и обновление

`uv` уже доступен в MSYS2 Bash:

```bash
uv --version
```

## Виртуальные окружения

```bash
# Создать окружение
uv venv .venv

# Активировать
source .venv/bin/activate

# Деактивировать
deactivate
```

## Установка пакетов

```bash
# Установить пакет
uv pip install requests

# Установить из requirements.txt
uv pip install -r requirements.txt

# Обновить пакет
uv pip install --upgrade requests

# Зафиксировать зависимости
uv pip freeze > requirements.txt
```

## Запуск скриптов

```bash
# Запустить скрипт в изолированном окружении
uv run script.py

# Запустить с аргументами
uv run script.py arg1 arg2

# Выполнить команду из пакета
uv run --with httpie http GET https://api.example.com
```

## Работа с Python

```bash
# Установить конкретную версию Python
uv python install 3.12

# Использовать версию Python для проекта
uv python pin 3.12
```
