# wget

Загрузка файлов по HTTP/HTTPS/FTP.

## Основные примеры

```bash
# Скачать файл
wget https://example.com/file.zip

# Сохранить под другим именем
wget -O archive.zip https://example.com/file.zip

# Скачать в указанную папку
wget -P downloads https://example.com/file.zip
```

## Продолжение и зеркалирование

```bash
# Продолжить прерванную загрузку
wget -c https://example.com/large.iso

# Зеркалировать сайт
wget --mirror --convert-links --adjust-extension --page-requisites \
  --no-parent https://example.com/docs/
```

## Ограничения и фон

```bash
# Ограничить скорость
wget --limit-rate=1m https://example.com/large.iso

# Загрузка в фоне
wget -b https://example.com/large.iso
```

## Аутентификация

```bash
# Basic Auth
wget --user=user --password=password https://example.com/private
```

## Полезные флаги

```bash
# Не проверять сертификат (только для отладки)
wget --no-check-certificate https://self-signed.example.com

# Тихий режим
wget -q https://example.com/file.zip
```
