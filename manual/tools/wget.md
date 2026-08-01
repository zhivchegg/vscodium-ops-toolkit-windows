# wget

Загрузка файлов по HTTP/HTTPS/FTP. Полезен для скачивания логов, архивов и зеркалирования документации.

## Что проверить при инциденте

1. Доступен ли URL?
2. Нужно ли скачать большой файл с возможностью докачки?
3. Требуется ли аутентификация?

## Основные примеры

```bash
# Скачать файл
wget https://example.com/file.zip

# Сохранить под другим именем
wget -O archive.zip https://example.com/file.zip

# Скачать в указанную папку
wget -P downloads https://example.com/file.zip

# Тихий режим
wget -q https://example.com/file.zip
```

## Продолжение и большие файлы

```bash
# Продолжить прерванную загрузку
wget -c https://example.com/large.iso

# Ограничить скорость
wget --limit-rate=1m https://example.com/large.iso

# Загрузка в фоне
wget -b https://example.com/large.iso
```

## Зеркалирование

```bash
# Скачать сайт локально
wget --mirror --convert-links --adjust-extension --page-requisites \
  --no-parent https://example.com/docs/
```

## Аутентификация

```bash
# Basic Auth
wget --user=user --password=password https://example.com/private

# Bearer-токен
wget --header="Authorization: Bearer $TOKEN" https://example.com/private
```

## Проверка доступности URL

```bash
wget --spider https://example.com/health
```

## Практический пример: скачивание дампа логов

```bash
# С докачкой и авторизацией
wget -c --header="Authorization: Bearer $TOKEN" \
  -O /tmp/app-dump.log \
  https://logs.example.com/export/app-dump.log
```

## Подводные камни

- По умолчанию wget сохраняет файл под именем из URL — используйте `-O`, если нужно другое имя.
- `wget --no-check-certificate` отключает проверку TLS — только для отладки.
- При зеркалировании следите за robots.txt — `--mirror` учитывает его по умолчанию.
- В MSYS2 пути с обратными слешами в `-P` могут работать некорректно — используйте прямые слеши.
