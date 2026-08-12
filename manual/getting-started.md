# Руководство по запуску и использованию VSCodium Ops Toolkit

Полное пошаговое руководство по портативной сборке VSCodium + MSYS2 для Windows, предназначенной для работы без прав администратора и без интернета на целевой машине.

## Содержание

1. [Что это такое](#what-is-it)
2. [Требования и ограничения](#requirements)
3. [Распаковка архива](#unpack)
4. [Первый запуск](#first-run)
5. [Проверка окружения](#check-env)
6. [Настройка Python и Java](#runtime-config)
7. [Как пользоваться VSCodium](#vscodium-usage)
8. [Интегрированный терминал](#terminal)
9. [Работа с проектами](#projects)
10. [Работа с Git](#git)
11. [Работа с SSH](#ssh)
12. [Работа с Kubernetes](#kubernetes)
13. [Работа с PostgreSQL](#postgresql)
14. [Работа с Kafka](#kafka)
15. [Анализ логов](#log-analysis)
16. [Создание ярлыков](#shortcuts)
17. [Перенос или перемещение сборки](#moving)
18. [Офлайн-использование](#offline)
19. [Настройки производительности](#performance)
20. [Безопасность и личные данные](#security)
21. [Где что хранится](#locations)
22. [Решение проблем](#troubleshooting)
23. [Чего не делать](#dont-do)
24. [Ссылки на другие мануалы](#links)

---

## <a id="what-is-it"></a>Что это такое

VSCodium Ops Toolkit — это портативная сборка редактора **VSCodium** с предустановленными расширениями и полноценным **MSYS2** bash-окружением. Всё упаковано в одну папку `VSCodium-portable/`, которую можно распаковать в любое место и запускать без установки.

### Что входит в сборку

- **Редактор:** VSCodium (VS Code без телеметрии Microsoft).
- **Терминал:** MSYS2 Bash с `git`, `ssh`, `curl`, `wget`, `kubectl`, `helm`, `psql`, `shellcheck`, `jq`, `tmux`, `mc`, `vim`, `nano`, `tar`, `gzip`, `7z` и другими утилитами.
- **Расширения:** Git Graph, Git History, Python, Bash IDE, Language Support for Java, Kubernetes, Docker, PostgreSQL, Kafka for VS Code, REST Client, XML/YAML, JSON, Material Icon Theme, indent-rainbow.
- **Скрипты запуска:**
  - `start-vscodium.cmd` — запуск редактора с правильным MSYS2 PATH.
  - `msys2-bash.cmd` — отдельное окно MSYS2 Bash.
  - `configure-runtime.cmd` — настройка внешнего Python и Java.
  - `create-shortcuts.cmd` — создание ярлыков на рабочем столе или в текущей папке.

### Что НЕ входит в сборку (подключается отдельно)

- **Python** — портативный интерпретатор с заранее установленными пакетами.
- **Java** — портативный JDK (версия по выбору).
- **Kafka CLI** — бинарные файлы Apache Kafka.

Эти компоненты не включены, чтобы уменьшить размер архива и дать возможность выбрать версию.

---

## <a id="requirements"></a>Требования и ограничения

- **ОС:** Windows 10/11 (64 бит).
- **Права:** не требуются права администратора.
- **Архитектура:** x86_64.
- **Минимальные ресурсы:** как в реальности работает на 4 vCPU / 16 GB RAM, но комфорт — по ситуации.
- **Место на диске:** после распаковки около 1.2–1.5 GB (без Python/Java).
- **Для распаковки:** желательно использовать **7-Zip Portable** или стационарный 7-Zip. Встроенный архиватор Windows не умеет создавать символические ссылки без прав администратора и выдаст ошибку на `msys64/etc/mtab`.
- **Интернет:** на целевой машине не нужен. Python/Java готовятся заранее на машине с интернетом.

---

## <a id="unpack"></a>Распаковка архива

1. Скачайте актуальный архив с GitHub Releases:
   - `VSCodium-portable.7z` — меньше размер, извлекать через 7-Zip.
   - `VSCodium-portable.zip` — больше размер, но тоже работает с 7-Zip.
2. Откройте 7-Zip и распакуйте архив **на диск с файловой системой NTFS** (FAT32 не поддерживает симлинки и права).
3. Рекомендуется путь без пробелов и желательно латиницей, например:
   ```text
   D:\Tools\VSCodium-portable
   ```
   Сборка работает и в путях с кириллицей/пробелами, но некоторые скрипты и сторонние утилиты ведут себя предсказуемее на латинице.
4. Если 7-Zip спросит про символические ссылки — соглашайтесь. Один symlink (`msys64/etc/mtab`) останется внутри окружения, это нормально.
5. Если вы использовали встроенный архиватор Windows и получили ошибку
   ```text
   Cannot create symbolic link : Клиент не обладает требуемыми правами
   ```
   — удалите неполную распаковку и используйте 7-Zip.
6. После распаковки у вас должна появиться папка:
   ```text
   VSCodium-portable/
     VSCodium.exe
     start-vscodium.cmd
     msys2-bash.cmd
     configure-runtime.cmd
     create-shortcuts.cmd
     manual/
     data/
     msys64/
   ```

---

## <a id="first-run"></a>Первый запуск

Запускайте сборку только через `start-vscodium.cmd`, не через `VSCodium.exe`. Это гарантирует, что встроенный терминал увидит MSYS2-утилиты.

### Шаги

1. Откройте папку `VSCodium-portable/`.
2. Запустите `start-vscodium.cmd`.
3. Подождите, пока загрузится VSCodium.
4. Откройте терминал: `Ctrl + `` ` (обратный апостроф) или меню **Terminal → New Terminal**.
5. По умолчанию откроется **MSYS2 Bash**. При первом запуске bash может показать предупреждение об отсутствии `/tmp`. Это некритично — можно проигнорировать или создать папку вручную:
   ```bash
   mkdir -p /tmp
   ```

### Что происходит при запуске

- `start-vscodium.cmd` добавляет `msys64/usr/bin` и `msys64/mingw64/bin` вPATH Windows-переменную.
- Запускается `VSCodium.exe`.
- Встроенный терминал использует `bash.exe` из `msys64/usr/bin/bash.exe` (а не системный Git Bash или MSYS2, если они установлены отдельно).
- MSYS2 автоматически нормализует PATH в POSIX-формат при старте shell, чтобы `git-remote-https` и другие подпроцессы находили DLL.

---

## <a id="check-env"></a>Проверка окружения

Откройте терминал в VSCodium и выполните:

```bash
# Проверить bash
echo $SHELL
bash --version

# Проверить Git
git --version

# Проверить основные утилиты
which git curl ssh kubectl helm psql shellcheck jq tmux mc

# Проверить PATH
echo $PATH | tr ':' '\n'
```

Если все команды находятся и `git --version` выдаёт версию, окружение готово.

### Проверка Git через HTTPS

```bash
git clone https://github.com/zhivchegg/vscodium-ops-toolkit-windows.git test-clone
```

Если клон прошёл без ошибок, MSYS2 PATH настроен правильно.

---

## <a id="runtime-config"></a>Настройка Python и Java

Python и Java не входят в состав сборки. Их нужно подготовить на машине с интернетом и скопировать на целевую машину целиком в виде папок.

### Подготовка Python

На машине с интернетом установите в портативную папку Python и пакеты:

```bash
python -m pip install debugpy PyYAML yamllint requests rich python-dateutil jinja2 pytz click httpie
```

Минимально достаточно:

```bash
python -m pip install debugpy PyYAML yamllint
```

Скопируйте всю папку с Python на целевую машину (например, рядом с `VSCodium-portable/` или внутрь неё).

### Подготовка Java

Скачайте portable JDK (например, Eclipse Temurin или Amazon Corretto), распакуйте и скопируйте папку на целевую машину. Внутри папки должен быть `bin/java.exe`.

### Настройка через configure-runtime.cmd

1. Закройте VSCodium (если открыт).
2. Запустите `configure-runtime.cmd`.
3. В окне две независимые секции: **Python** и **Java**.
4. Для каждого:
   - нажмите **Browse...** и выберите папку, где лежит `python.exe` (или `bin/java.exe` для Java);
   - нажмите **Test** — должна появиться версия;
   - нажмите **Save** — путь сохранится в `settings.json` и в `msys64/etc/profile.d/runtime.sh`.
5. Закройте окно.
6. Запустите VSCodium через `start-vscodium.cmd`.

### Проверка в терминале

```bash
python --version
which python
python3 --version
java -version
which java
```

> **Важно:** пути к Python/Java сохраняются абсолютными. Если вы переместите папку `VSCodium-portable`, запустите `configure-runtime.cmd` заново.

---

## <a id="vscodium-usage"></a>Как пользоваться VSCodium

### Основные сочетания клавиш

| Действие | Сочетание |
|---|---|
| Командная панель | `Ctrl + Shift + P` |
| Терминал | `` Ctrl + ` `` |
| Быстрый поиск файлов | `Ctrl + P` |
| Проводник | `Ctrl + Shift + E` |
| Панель Problems | `Ctrl + Shift + M` |
| Найти по проекту | `Ctrl + Shift + F` |
| Форматирование | `Shift + Alt + F` |
| Запуск отладки | `F5` |

### Открытие папки с проектом

1. **File → Open Folder...**
2. Выберите папку с деплой-конфигом, логами или кодом.
3. Если VSCodium спросит "Do you trust the authors of the files in this folder?" — подтвердите, иначе расширения не заработают.

### Command Palette

Большинство команд плагинов доступны через `Ctrl + Shift + P`. Например:

- `Python: Select Interpreter`
- `Java: Configure Java Runtime`
- `Kubernetes: Use Namespace`
- `Git: Clone`

### Отключены по умолчанию

Для офлайн/слабых машин отключены:

- автообновления расширений;
- автоформатирование при сохранении;
- автофетч Git;
- schema store для YAML;
- Kubernetes CRD store;
- эксперименты и telemetry.

Эти настройки находятся в `data/user-data/User/settings.json` и при необходимости могут быть изменены.

---

## <a id="terminal"></a>Интегрированный терминал

Терминал в VSCodium запускает MSYS2 Bash, который разделяет Git, SSH и домашнюю папку с внутренним миром сборки.

### Домашняя папка MSYS2

```bash
echo $HOME
# Пример: C:/Users/Евгений/Documents/vscodium/VSCodium-portable/msys64/home/Евгений
```

Все файлы вида `~/.ssh`, `~/.bash_aliases`, `~/.kube/config` живут внутри `msys64/home/<имя_пользователя>/`. Это важно для SSH-ключей и Git-конфигурации.

### Преобразование путей Windows ↔ MSYS2

```bash
# Windows путь в MSYS2
/cygdrive/c/Users/Евгений/Desktop
# или
c:/Users/Евгений/Desktop

# Автоматическое преобразование
cygpath -u 'C:\Users\Евгений\Desktop'
# -> /c/Users/Евгений/Desktop

cygpath -w '/c/Users/Евгений/Desktop'
# -> C:\Users\Евгений\Desktop
```

### Персональные настройки

Создайте файлы в `~` (внутри MSYS2):

- `~/.bash_aliases` — алиасы команд.
- `~/.bashrc` — персональные настройки (но основной конфиг уже прописан в `etc/skel/.bashrc`).
- `~/.ssh/config` — быстрые SSH-подключения.
- `~/.kube/config` — Kubernetes-конфиг.

### Пример алиасов

```bash
# ~/.bash_aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias ll='ls -la'
alias err='grep -i -E "error|exception|fatal"'
```

Применить:

```bash
source ~/.bash_aliases
```

Чтобы загружались автоматически, в `~/.bashrc` должен быть блок:

```bash
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

---

## <a id="projects"></a>Работа с проектами

### Структура проекта в VSCodium

1. Откройте папку с проектом через **File → Open Folder...**.
2. В Explorer слева появятся файлы.
3. Для YAML/JSON-файлов доступны подсветка, валидация и схемы (встроенные или из плагинов).

### Полезные настройки для больших деплой-проектов

В `settings.json` уже добавлены исключения для индексации:

```json
"files.exclude": {
    "**/.git": true,
    "**/node_modules": true,
    "**/target": true,
    "**/build": true,
    "**/.cache": true
}
```

Если проект содержит огромные папки (например, `logs/` по нескольку GB), добавьте их в исключения вручную:

```json
"files.exclude": { "**/logs": true }
"search.exclude": { "**/logs": true }
"files.watcherExclude": { "**/logs/**": true }
```

### Workspace

Если нужно работать с несколькими папками одновременно:

1. **File → Save Workspace As...**
2. Добавьте папки через **File → Add Folder to Workspace**.
3. Файл workspace сохраняется как `.code-workspace`.

---

## <a id="git"></a>Работа с Git

Git в сборке используется общий для VSCodium и терминала. Ключи и конфигурация хранятся в `~/.ssh` и `~/.gitconfig` внутри MSYS2.

### Настройка пользователя

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Клонирование

```bash
# HTTPS
git clone https://github.com/username/repo.git

# SSH (если настроены ключи)
git clone git@github.com:username/repo.git
```

### SSH-ключи для Git

1. Сгенерируйте ключ в MSYS2:
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519 -N ""
   ```
2. Поставьте права:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```
3. Публичный ключ добавьте в GitHub/GitLab:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
4. Проверьте подключение:
   ```bash
   ssh -T git@github.com
   ```

Подробнее см. [manual/tools/ssh.md](tools/ssh.md).

### Расширения Git

- **Git Graph** — визуальная история коммитов.
- **Git History** — детальная история по файлу.
- Встроенный Git в VSCodium показывает изменения в боковой панели Source Control.

---

## <a id="ssh"></a>Работа с SSH

SSH используется для подключения к серверам, туннелей и копирования файлов. Все ключи и настройки — в MSYS2-профиле.

### Быстрое подключение

```bash
ssh user@server.example.com
ssh -p 2222 user@server.example.com
```

### Выполнение команды удалённо

```bash
ssh user@server.example.com "df -h"
```

### Копирование файлов

```bash
# Один файл
scp file.log user@server:/var/log/

# Папка
scp -r ./logs user@server:/var/log/

# Rsync через SSH
rsync -avz --progress ./logs/ user@server:/var/log/
```

### Туннели

```bash
# Локальный туннель: порт 8080 на вашей машине -> порт 80 на сервере
ssh -L 8080:localhost:80 user@server

# Через bastion
ssh -J user@bastion user@internal-server

# SOCKS-прокси
ssh -D 1080 user@server
```

Подробнее см. [manual/tools/ssh.md](tools/ssh.md).

---

## <a id="kubernetes"></a>Работа с Kubernetes

kubectl и helm уже в PATH. Конфигурация кластера читается из `~/.kube/config`.

### Настройка kubeconfig

```bash
mkdir -p ~/.kube
cp /path/to/kubeconfig ~/.kube/config
chmod 600 ~/.kube/config
```

### Основные команды

```bash
# Информация о кластере
kubectl cluster-info
kubectl get nodes

# Поды
kubectl get pods -A
kubectl get pods -n my-ns

# Логи
kubectl logs -n my-ns deployment/my-app --tail=100 -f

# Выполнить команду в поде
kubectl exec -it -n my-ns pod/my-app -- sh

# Проброс порта
kubectl port-forward -n my-ns pod/my-app 8080:80

# Применить манифест
kubectl apply -f deployment.yaml

# Helm
helm list -A
helm upgrade --install my-app ./chart
```

### Плагины Kubernetes в VSCodium

- Просмотр кластеров в боковой панели Kubernetes.
- Для работы в офлайне отключены schema store и CRD store, поэтому автодополнение YAML может быть ограничено.
- Lint Kubernetes отключен, чтобы не требовать интернета.

Подробнее см. [manual/plugins/Kubernetes.md](plugins/Kubernetes.md) и [manual/tools/kubectl.md](tools/kubectl.md).

---

## <a id="postgresql"></a>Работа с PostgreSQL

В сборке есть `psql` и плагин PostgreSQL для VSCodium.

### Подключение через psql

```bash
psql -h localhost -U postgres -d mydb
psql "postgresql://user:pass@host:5432/dbname"
```

### Использование pg_service.conf и .pgpass

Положите файлы в папку `config/` рядом с `VSCodium-portable/`:

```text
VSCodium-portable/
  config/
    pg_service.conf
    pgpass
```

Пример `pg_service.conf`:

```ini
[prod-db]
host=prod-db.example.com
port=5432
dbname=mydb
user=ops
```

Подключение:

```bash
psql service=prod-db
```

Подробнее см. [manual/plugins/PostgreSQL.md](plugins/PostgreSQL.md).

---

## <a id="kafka"></a>Работа с Kafka

CLI-утилиты Kafka (kafka-console-consumer, kafka-topics и др.) не входят в сборку. Их нужно скачать отдельно с сайта Apache Kafka.

### Добавление Kafka CLI

1. Скачайте `kafka_<scala>_<version>.tgz` с официального сайта.
2. Распакуйте в удобное место, например `D:\Tools\kafka\`.
3. Добавьте папку `bin\windows\` или `bin\` в PATH через `~/.bash_aliases`:
   ```bash
   export PATH="/d/Tools/kafka/bin:$PATH"
   ```

### Плагин в VSCodium

Расширение **Kafka for VS Code** позволяет просматривать топики и сообщения, если есть доступ к брокеру.

Подробнее см. [manual/plugins/Kafka.md](plugins/Kafka.md).

---

## <a id="log-analysis"></a>Анализ логов

Сборка предназначена для анализа текстовых логов, JSON-логов и конфигов.

### Просмотр логов

```bash
# Постраничный просмотр
less /var/log/app.log

# В реальном времени
tail -f /var/log/app.log

# Последние 100 строк
tail -n 100 /var/log/app.log
```

### Поиск ошибок

```bash
# Регистронезависимый поиск
grep -i error app.log

# Поиск по нескольким шаблонам
grep -i -E "error|exception|fatal" app.log

# Подсчёт повторений
sort app.log | uniq -c | sort -rn
```

### JSON-логи

```bash
# Извлечь уровни
jq '.level' app.json

# Отфильтровать ошибки
jq 'select(.level == "ERROR")' app.json

# Статистика по уровням
jq -r '.level' app.json | sort | uniq -c | sort -rn
```

### Сессии с несколькими окнами

```bash
tmux new -s logs
tmux split-window -h
tmux split-window -v
```

Подробнее см. [manual/tools/less.md](tools/less.md), [manual/tools/grep.md](tools/grep.md), [manual/tools/jq.md](tools/jq.md), [manual/tools/tmux.md](tools/tmux.md).

---

## <a id="shortcuts"></a>Создание ярлыков

Запустите `create-shortcuts.cmd`. Откроется окно выбора:

- **Desktop** — создаёт ярлыки на рабочем столе.
- **Current folder** — создаёт ярлыки в папке `VSCodium-portable/`.

Создаются ярлыки:

- `VSCodium Ops Toolkit.lnk` — запуск редактора.
- `MSYS2 Bash.lnk` — отдельное окно MSYS2 Bash.
- `Configure Runtime.lnk` — настройка Python/Java.

### Ограничения Windows

- Windows не позволяет закреплять на панели задач ярлыки, указывающие на `.cmd` файлы, если путь к `.cmd` лежит через `.lnk`. Это ограничение Windows, не сборки.
- После перемещения папки `VSCodium-portable` запустите `create-shortcuts.cmd` заново, чтобы обновить пути в ярлыках.

---

## <a id="moving"></a>Перенос или перемещение сборки

Сборка портативна, но есть нюансы.

### Что сохранится

- Все настройки VSCodium (расширения, `settings.json`).
- MSYS2-окружение и системные утилиты.
- `runtime.sh` (если он лежит внутри `msys64/etc/profile.d/`).

### Что нужно перенастроить

1. **Python и Java** — запустите `configure-runtime.cmd` и укажите пути к интерпретатору/JDK на новом месте.
2. **Ярлыки** — пересоздайте через `create-shortcuts.cmd`.
3. **SSH-ключи и конфиги** — находятся в `msys64/home/<user>/`. Перенесите их вручную или создайте заново.
4. **kubeconfig** — перенесите `~/.kube/config`.
5. **pg_service.conf / pgpass** — перенесите из `config/`.
6. **`.bash_aliases`** — перенесите из MSYS2-домашней папки.

### Порядок переноса

1. Закройте VSCodium.
2. Упакуйте папку `VSCodium-portable/` обратно в архив или скопируйте целиком.
3. Перенесите на целевую машину.
4. Распакуйте через 7-Zip.
5. Запустите `start-vscodium.cmd` и проверьте терминал.
6. Запустите `configure-runtime.cmd`, укажите Python/Java.
7. Пересоздайте ярлыки и перенесите личные конфиги.

---

## <a id="offline"></a>Офлайн-использование

Сборка не требует интернета для работы. Всё, что нужно, уже внутри архива или подключается вручную.

### Что отключено

- Автообновления расширений.
- Проверка обновлений.
- Schema store и Kubernetes CRD store.
- Автофетч Git.
- Эксперименты и телеметрия.

### Что нужно подготовить заранее

- Python с нужными пакетами.
- JDK, если работаете с Java.
- Kafka CLI, если нужен.
- SSH-ключи, kubeconfig, pg_service.conf, .bash_aliases.

### Работа с документацией

Мануалы находятся в `manual/`. При необходимости распечатайте или откройте в VSCodium.

---

## <a id="performance"></a>Настройки производительности

Сборка уже настроена для слабых машин и больших деплой-проектов.

### Что уже сделано

- `java.server.launchMode: LightWeight` — Java Language Server работает в облегчённом режиме.
- `python.analysis.indexing: false` — Python не индексирует весь проект.
- Отключены автоформатирование, автообновления, автофетч.
- Исключены из индексации: `.git`, `node_modules`, `target`, `build`, `.cache`, логи, архивы.

### Если VSCodium тормозит

1. Закройте ненужные папки в Explorer.
2. Отключите неиспользуемые расширения: **Extensions → Installed → Disable**.
3. Добавьте большие папки в `files.exclude` и `files.watcherExclude`.
4. Уменьшите количество открытых вкладок.
5. Для Java-анализа используйте только нужные папки, открывая их как workspace folders.

### Мониторинг ресурсов

В терминале можно быстро оценить нагрузку:

```bash
# Процессы, CPU, память
ps aux --sort=-%mem | head

# Диск
df -h

# Размер папок
du -sh */
```

---

## <a id="security"></a>Безопасность и личные данные

- Сборка не требует прав администратора.
- Не храните пароли в открытом виде в `settings.json` или `.cmd`.
- SSH-ключи должны иметь права `600`.
- Папка `~/.ssh` — `700`.
- `kubeconfig` — `600`.
- `pgpass` — `600`.

Личные файлы (`~/.ssh`, `~/.kube`, `~/.bash_aliases`, `config/pg_service.conf`, `config/pgpass`) не входят в архив и не попадают в git-репозиторий исходников.

---

## <a id="locations"></a>Где что хранится

| Что | Где |
|---|---|
| Настройки VSCodium | `data/user-data/User/settings.json` |
| Расширения | `data/extensions/` |
| MSYS2 home (SSH, Git config, kubeconfig) | `msys64/home/<имя_пользователя>/` |
| MSYS2 глобальные настройки | `msys64/etc/` |
| Python/Java runtime.sh | `msys64/etc/profile.d/runtime.sh` |
| PostgreSQL сервис-конфиг | `config/pg_service.conf` |
| PostgreSQL пароли | `config/pgpass` |
| Kubernetes kubeconfig | `config/kubeconfig` (если включён) или `~/.kube/config` |
| Мануалы | `manual/` |
| Временные файлы MSYS2 | `msys64/tmp/` |

---

## <a id="troubleshooting"></a>Решение проблем

### Не запускается `start-vscodium.cmd`

Проверьте, что папка на NTFS и путь не превышает `MAX_PATH` (260 символов). При необходимости перенесите ближе к корню диска.

### В терминале не находятся git, kubectl, psql

1. Закройте VSCodium.
2. Запустите `start-vscodium.cmd`, а не `VSCodium.exe`.
3. В терминале выполните:
   ```bash
   echo $PATH
   which git
   ```
   Если пути не содержат `msys64/usr/bin`, проверьте `start-vscodium.cmd`.

### `git clone` падает с ошибкой DLL

Причина: MSYS2 не может найти DLL из-за Windows-формата PATH.

Решение: убедитесь, что в `msys64/etc/profile.d/vscodium-ops-toolkit.sh` есть строка:

```bash
PATH="/usr/local/bin:/usr/bin:/bin:/mingw64/bin:${PATH}"
```

### Ошибка при распаковке: Cannot create symbolic link

Используйте 7-Zip, а не встроенный архиватор Windows.

### Предупреждение "could not find /tmp"

Создайте папку вручную:

```bash
mkdir -p /tmp
```

В свежих версиях архива папка `msys64/tmp/` уже может присутствовать.

### Antivirus/Defender блокирует `.cmd` или `.exe`

- Добавьте папку `VSCodium-portable/` в исключения антивируса.
- Если `.exe` не закрепляется на панели задач — это ограничение Windows для `.cmd` ярлыков.

### VSCodium не видит интерпретатор Python

1. Проверьте `settings.json`:
   ```json
   "python.defaultInterpreterPath": "${execPath}\\..\\python\\python.exe"
   ```
2. Убедитесь, что путь существует.
3. Перезапустите VSCodium через `start-vscodium.cmd`.

### Java Language Server медленный или не запускается

- Убедитесь, что `java.jdt.ls.java.home` указывает на правильный JDK.
- Проверьте, что режим `LightWeight` включён (`java.server.launchMode`).

### Расширения не активируются

- Проверьте, что папка с проектом добавлена в Trusted Folders.
- Проверьте, что расширения не отключены.

---

## <a id="dont-do"></a>Чего не делать

- **Не запускайте `VSCodium.exe` напрямую** — терминал не получит MSYS2 PATH.
- **Не перемещайте `msys64/` отдельно от `VSCodium.exe`** — пути развалятся.
- **Не используйте встроенный архиватор Windows** — проблемы с symlink.
- **Не храните личные ключи и пароли внутри папки, которую хотите выложить в git/релиз.**
- **Не включайте автообновления расширений в офлайн-контуре** — это приведёт к ошибкам.

---

## <a id="links"></a>Ссылки на другие мануалы

### Плагины VSCodium

- [Bash IDE](plugins/Bash-IDE.md)
- [Docker](plugins/Docker.md)
- [Git](plugins/Git.md)
- [JSON](plugins/JSON.md)
- [Kafka](plugins/Kafka.md)
- [Kubernetes](plugins/Kubernetes.md)
- [PostgreSQL](plugins/PostgreSQL.md)
- [Python](plugins/Python.md)
- [REST Client](plugins/REST-Client.md)
- [XML-YAML](plugins/XML-YAML.md)

### Инструменты командной строки

- [awk](tools/awk.md)
- [curl](tools/curl.md)
- [grep](tools/grep.md)
- [jq](tools/jq.md)
- [kubectl](tools/kubectl.md)
- [less](tools/less.md)
- [mc](tools/mc.md)
- [sed](tools/sed.md)
- [ssh](tools/ssh.md)
- [tmux](tools/tmux.md)
- [uv](tools/uv.md)
- [wget](tools/wget.md)
