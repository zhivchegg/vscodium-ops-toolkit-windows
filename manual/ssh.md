# ssh

Удалённые подключения и выполнение команд по SSH.

## Основные примеры

```bash
# Подключиться к серверу
ssh user@server.example.com

# Указать порт
ssh -p 2222 user@server.example.com

# Выполнить команду и вернуться
ssh user@server.example.com "df -h"

# Выполнить локальный скрипт на удалённом сервере
ssh user@server.example.com 'bash -s' < script.sh
```

## Ключи

```bash
# Сгенерировать ключ
ssh-keygen -t ed25519 -C "ops@example.com"

# Скопировать публичный ключ на сервер
ssh-copy-id user@server.example.com

# Использовать конкретный ключ
ssh -i ~/.ssh/id_ed25519 user@server.example.com
```

## Туннели и порты

```bash
# Локальный туннель: порт 8080 -> сервер:80
ssh -L 8080:localhost:80 user@server.example.com

# Удалённый туннель: порт сервера 9090 -> локальный:3000
ssh -R 9090:localhost:3000 user@server.example.com

# SOCKS-прокси
ssh -D 1080 user@server.example.com
```

## Файлы

```bash
# Копировать файл по SCP
scp file.log user@server.example.com:/var/log/

# Копировать папку
scp -r ./logs user@server.example.com:/var/log/
```
