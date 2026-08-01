# VSCodium Ops Toolkit

Портативная сборка **VSCodium** с предустановленными плагинами и полноценным bash-окружением MSYS2 для задач сопровождения, отладки, чтения логов, написания скриптов и автоматизации рутины.

## Состав

### VSCodium

- [VSCodium](https://vscodium.com/) 1.126.04524 (Windows x64 portable)
- Portable-режим: все настройки, расширения и пользовательские данные хранятся в папке `data/` рядом с `VSCodium.exe`

### MSYS2 Bash-окружение

Предустановленные пакеты:

| Пакет | Назначение |
|---|---|
| `bash` | Shell |
| `coreutils` | Базовые утилиты: cat, cut, sort, uniq, wc и др. |
| `grep` | Поиск по тексту |
| `sed` | Потоковая обработка текста |
| `gawk` | awk |
| `findutils` | find, xargs |
| `diffutils` | diff, cmp |
| `curl` | HTTP-запросы |
| `wget` | Загрузка файлов |
| `jq` | Обработка JSON |
| `openbsd-netcat` | nc — работа с сокетами |
| `openssh` | ssh, scp, sftp |
| `rsync` | Синхронизация файлов |
| `git` | Система контроля версий |
| `tar`, `gzip`, `zip`, `unzip` | Архиваторы |
| `p7zip` | 7zip архиватор |
| `vim` | Редактор с подсветкой синтаксиса |
| `nano` | Простой текстовый редактор |
| `mc` | Midnight Commander |

### Плагины VSCodium

| Категория | Плагин |
|---|---|
| **Git** | GitLens, Git Graph, Git History |
| **HTTP-запросы** | REST Client |
| **Python** | Python (Microsoft) |
| **JavaScript/TypeScript** | ESLint, Prettier |
| **Java** | Language Support for Java by Red Hat, Debugger for Java |
| **Bash** | Bash IDE, shellcheck |
| **XML** | XML (Red Hat) |
| **YAML** | YAML (Red Hat) |
| **Kubernetes** | Kubernetes Tools |
| **Docker** | Docker |
| **PostgreSQL** | PostgreSQL |
| **Kafka** | Kafka for VS Code |
| **Внешний вид** | Material Icon Theme, indent-rainbow |

## Запуск

1. Распакуйте архив `VSCodium-portable.zip`.
2. Запустите `VSCodium-portable/start-vscodium.cmd`.
3. Терминал по умолчанию откроется как **MSYS2 Bash**.

> **Важно:** используйте именно `start-vscodium.cmd`, чтобы MSYS2 bash был доступен в терминале. Запуск `VSCodium.exe` напрямую не добавит MSYS2 в PATH.

## Проверка после запуска

В терминале VSCodium выполните:

```bash
bash --version
curl --version
jq --version
git --version
ssh -V
nc -h
vim --version
```

## Настройки

- Расширения: `VSCodium-portable/data/extensions/`
- Пользовательские настройки: `VSCodium-portable/data/user-data/User/settings.json`
- Конфигурация vim: `VSCodium-portable/msys64/etc/vimrc`

## Лицензия

Сборка распространяется под лицензией MIT. Подробнее см. [LICENSE](LICENSE).

Компоненты сборки (VSCodium, MSYS2, расширения) имеют собственные лицензии.
