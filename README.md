# VSCodium Ops Toolkit — Windows

Портативная сборка VSCodium с предустановленными плагинами и MSYS2 bash-окружением для задач сопровождения, отладки, анализа логов и автоматизации.

## Быстрый старт

1. Распакуйте архив в любую папку.
2. Запустите `start-vscodium.cmd`.
3. Дождитесь загрузки VSCodium.
4. Откройте терминал — по умолчанию откроется MSYS2 Bash.

> **Важно:** запускайте именно `start-vscodium.cmd`, чтобы MSYS2 bash и все утилиты были доступны в терминале.  
> VSCodium и терминал используют общий Git и SSH из MSYS2, поэтому ключи для Git хранятся в `msys64/home/<имя_пользователя>/.ssh` (см. `manual/tools/ssh.md`).

## Настройка Python и Java

Python и Java не включены в сборку, чтобы не увеличивать размер. Подключите свои portable-версии через графическое окно:

1. Запустите `configure-runtime.cmd`.
2. В окне видны две независимые секции: **Python** и **Java**.
3. В каждой секции:
   - показана текущая сохранённая настройка (или `not configured`)
   - поле с путём — можно вставить вручную или выбрать через кнопку **Browse...**
   - кнопка **Test** проверяет, что программа работает
   - кнопка **Save** сохраняет путь в `settings.json` и `runtime.sh`
   - кнопка **Clear** удаляет настройку
4. Перезапустите VSCodium через `start-vscodium.cmd`.

> Python и Java настраиваются отдельно — можно включить только одно из них.

### Требования к внешнему Python

Подключаемый интерпретатор должен быть подготовлен на машине с интернетом и содержать следующие пакеты:

```text
debugpy
PyYAML
yamllint
requests
rich
python-dateutil
jinja2
pytz
click
httpie
```

Минимальный набор:

```text
debugpy
PyYAML
yamllint
```

Установите заранее:

```bash
python -m pip install debugpy PyYAML yamllint requests rich python-dateutil jinja2 pytz click httpie
```

После установки скопируйте всю папку с Python на целевую машину и укажите путь к `python.exe` в `configure-runtime.cmd`.

### Требования к внешней Java

Укажите папку `JAVA_HOME`, содержащую `bin\java.exe`. JDK должна быть перенесена на целевую машину полностью.

## Что включено в терминал

- `bash`, `grep`, `sed`, `awk`, `find`, `xargs`
- `curl`, `wget`, `jq`
- `git`, `ssh`, `scp`, `rsync`
- `nc` (netcat)
- `kubectl`, `helm`, `uv`, `psql`, `shellcheck`
- все внутренние пути резолвятся относительно папки `VSCodium-portable/` — можно распаковывать куда угодно
- `tar`, `gzip`, `zip`, `unzip`, `7z`
- `vim`, `nano`, `mc`, `tmux`, `less`

## Плагины VSCodium

- Git: Git Graph, Git History
- HTTP: REST Client
- Python: Python (Microsoft)
- JS/TS: ESLint, Prettier
- Java: Language Support for Java by Red Hat, Debugger for Java
- Bash: Bash IDE, shellcheck
- XML/YAML: Red Hat XML, Red Hat YAML
- JSON: встроенная поддержка (валидация, форматирование, схемы)
- Kubernetes, Docker
- PostgreSQL, Kafka for VS Code
- UI: Material Icon Theme, indent-rainbow

## Анализ логов

Примеры команд в терминале:

```bash
# Просмотр лога
less /var/log/app.log

# Мониторинг в реальном времени
tail -f /var/log/app.log

# Поиск ошибок
grep -i error app.log
err < app.log

# Обработка JSON-логов
cat app.json | jq '.level'
cat app.json | jq 'paths' | grep level

# Несколько логов одновременно
tmux new -s logs
```

## Мануал по использованию

Справочники находятся в папке `manual/` и разделены на две группы:

- `manual/plugins/` — плагины VSCodium: REST Client, Python, Bash IDE, Git, PostgreSQL, Kubernetes, Docker, Kafka, XML/YAML, JSON.
- `manual/tools/` — bash-утилиты: grep, sed, awk, jq, curl, wget, ssh, tmux, less, mc, kubectl, uv.

Откройте `manual/README.md` для навигации.

## Структура папок

```
VSCodium-portable/
  VSCodium.exe                       # редактор
  start-vscodium.cmd                 # запуск VSCodium с MSYS2 PATH
  msys2-bash.cmd                     # запуск MSYS2 Bash
  configure-runtime.cmd              # настройка Python/Java
  create-shortcuts.cmd               # создание ярлыков
  create-shortcuts.ps1               # вспомогательный скрипт для create-shortcuts.cmd
  manual/                            # справочники по плагинам и утилитам
  data/                              # настройки и расширения
    extensions/                      # установленные плагины
    user-data/                       # пользовательские данные
  msys64/                            # bash-окружение
    usr/bin/bash.exe                 # shell по умолчанию
    etc/skel/.bashrc                 # bash-настройки
```

## Ярлыки

Запустите `create-shortcuts.cmd`. Он создаёт в текущей папке (или на рабочем столе — по выбору) ярлыки:

- `VSCodium Ops Toolkit.lnk` — запуск VSCodium
- `MSYS2 Bash.lnk` — запуск MSYS2 Bash в отдельном окне
- `Configure Runtime.lnk` — настройка Python/Java

Ярлыки можно копировать/перетаскивать в удобное место. Windows не позволяет закреплять на панели задач ярлыки, которые указывают на `.cmd` файлы. Если папку `VSCodium-portable` переместят, запустите `create-shortcuts.cmd` заново, чтобы обновить пути в ярлыках.

> Для быстрого запуска можно поместить `.lnk` на рабочий стол. Меню Пуск тоже распознаёт ярлыки, если их положить в `%APPDATA%\Microsoft\Windows\Start Menu\Programs\`.

## Оффлайн-использование

Сборка не требует интернета для работы. Не перемещайте папку `msys64` отдельно от `VSCodium.exe`.

## Лицензия

Сборка распространяется под лицензией MIT. Компоненты (VSCodium, MSYS2, расширения) имеют собственные лицензии.
