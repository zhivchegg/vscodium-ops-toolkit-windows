# ssh

Удалённые подключения и выполнение команд по SSH.

## Что проверить при инциденте

1. Доступен ли сервер по сети?
2. Открыт ли нужный порт?
3. Правильный ли ключ/пароль?
4. Не заблокирован ли IP?

## Подключение к серверу

```bash
# Стандартный порт 22
ssh user@server.example.com

# Нестандартный порт
ssh -p 2222 user@server.example.com

# Выполнить команду и вернуться
ssh user@server.example.com "df -h"

# Выполнить локальный скрипт на удалённом сервере
ssh user@server.example.com 'bash -s' < script.sh
```

## Управление ключами

```bash
# Сгенерировать ключ
ssh-keygen -t ed25519 -C "ops@example.com"

# Скопировать публичный ключ на сервер
ssh-copy-id user@server.example.com

# Использовать конкретный ключ
ssh -i ~/.ssh/id_ed25519 user@server.example.com

# Запустить ssh-agent
 eval $(ssh-agent -s)
 ssh-add ~/.ssh/id_ed25519
```

## Туннели и проброс портов

```bash
# Локальный туннель: порт 8080 на вашей машине -> порт 80 на сервере
ssh -L 8080:localhost:80 user@server.example.com

# Доступ к внутреннему сервису через bastion
ssh -L 8080:internal-service:80 user@bastion.example.com

# Удалённый туннель: порт на сервере -> ваш локальный порт
ssh -R 9090:localhost:3000 user@server.example.com

# SOCKS-прокси
ssh -D 1080 user@server.example.com
```

## Копирование файлов

```bash
# Один файл
scp file.log user@server.example.com:/var/log/

# Папка
scp -r ./logs user@server.example.com:/var/log/

# С указанием порта
scp -P 2222 file.log user@server.example.com:/var/log/
```

## Диагностика подключения

```bash
# Проверить доступность порта
nc -zv server.example.com 22

# Подробный вывод SSH
ssh -v user@server.example.com

# Ещё более подробно
ssh -vvv user@server.example.com
```

## Практический пример: сбор логов с нескольких серверов

```bash
#!/bin/bash
SERVERS=("web1" "web2" "app1")
for host in "${SERVERS[@]}"; do
    echo "=== $host ==="
    ssh "user@$host" "tail -n 100 /var/log/app.log | err" > "logs/$host-errors.log"
done
```

## Подводные камни

- `~/.ssh/config` упрощает подключения — настройте алиасы для частых хостов.
- Права на ключи должны быть `600` (`chmod 600 ~/.ssh/id_ed25519`).
- Если подключение зависает, проверьте DNS и MTU.
- `ssh -R` требует `GatewayPorts` на сервере для внешнего доступа.
