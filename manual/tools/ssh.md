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

## Конфигурация ~/.ssh/config

Упростите частые подключения:

```bash
Host prod-web
    HostName 192.168.1.10
    User ops
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

Host prod-db
    HostName db.example.com
    User postgres
    ProxyJump bastion
```

После этого можно подключаться так:

```bash
ssh prod-web
```

## Управление ключами

### Генерация нового ключа для Git

```bash
# Рекомендуемый тип ключа — ed25519
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519 -N ""

# Права доступа
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Вывести публичный ключ, чтобы добавить на GitHub/GitLab/etc.
cat ~/.ssh/id_ed25519.pub
```

Публичный ключ скопируй и добавь в настройки Git-сервера:  
**GitHub**: Settings → SSH and GPG keys → New SSH key.  
**GitLab**: Preferences → SSH Keys.

### Перенос ключей с основной Windows-машины в MSYS2

Портативная сборка живёт в папке `VSCodium-portable/`, а MSYS2 использует своё домашнее окружение внутри `VSCodium-portable/msys64/home/<имя_пользователя>/`. В этой сборке и VSCodium, и терминал используют **один и тот же Git и SSH из MSYS2**, поэтому ключи достаточно хранить только в MSYS2-профиле.

Чтобы работать с Git по SSH, перенеси ключи вручную:

1. Открой проводник Windows и найди папку с ключами:
   ```
   C:\Users\<твой_пользователь>\.ssh
   ```
   Обычно там лежат файлы: `id_ed25519`, `id_ed25519.pub`, `id_rsa`, `id_rsa.pub`, `config`, `known_hosts`.

2. Скопируй нужные файлы в папку MSYS2:
   ```
   VSCodium-portable\msys64\home\<имя_пользователя>\.ssh\
   ```
   Если папки `.ssh` нет — создай её.

3. Открой терминал MSYS2 (через `msys2-bash.cmd` или ярлык `MSYS2 Bash.lnk`, созданный `create-shortcuts.cmd`) и выставь права:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   chmod 644 ~/.ssh/config 2>/dev/null
   chmod 644 ~/.ssh/known_hosts 2>/dev/null
   ```

4. Проверь подключение к GitHub:
   ```bash
   ssh -T git@github.com
   ```
   Должен появиться ответ: `Hi username! You've successfully authenticated...`

### Использовать конкретный ключ

```bash
ssh -i ~/.ssh/id_ed25519 user@server.example.com
```

### Запустить ssh-agent

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_ed25519
```

## Туннели и проброс портов

```bash
# Локальный туннель: порт 8080 на вашей машине -> порт 80 на сервере
ssh -L 8080:localhost:80 user@server.example.com

# Доступ к внутреннему сервису через bastion
ssh -L 8080:internal-service:80 user@bastion.example.com

# Или через ProxyJump
ssh -J user@bastion.example.com user@internal-server

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

# rsync через SSH
rsync -avz --progress ./logs/ user@server.example.com:/var/log/
```

## Диагностика подключения

```bash
# Проверить доступность порта
nc -zv server.example.com 22

# Подробный вывод SSH
ssh -v user@server.example.com

# Ещё более подробно
ssh -vvv user@server.example.com

# Проверить, какой ключ используется
ssh -v user@server.example.com 2>&1 | grep "identity file"
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
- Права на ключи должны быть `600` (`chmod 600 ~/.ssh/id_ed25519`), на `~/.ssh` — `700`.
- Если подключение зависает, проверьте DNS и MTU.
- `ssh -R` требует `GatewayPorts` на сервере для внешнего доступа.
- `ProxyJump` удобнее цепочки туннелей — используйте `ssh -J` или `ProxyJump` в config.
