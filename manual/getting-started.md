# VSCodium Ops Toolkit — начало работы

> Эта страница открывается автоматически **при первом запуске** VSCodium Ops Toolkit.  
> **Важно:** редактор нужно запускать через `start-vscodium.cmd`, а не через `VSCodium.exe`. Иначе встроенный терминал не увидит MSYS2-утилиты (`git`, `kubectl`, `helm`, `psql` и др.).

## Как правильно запустить

1. Распакуйте архив **`VSCodium-portable.7z`** или **`VSCodium-portable.zip`** через **7-Zip**.  
   Встроенный архиватор Windows может выдать ошибку на символической ссылке `msys64/etc/mtab`.
2. Поместите папку `VSCodium-portable/` на диск с файловой системой NTFS. Желательно — путь без пробелов и латиницей, например `D:\Tools\VSCodium-portable`.
3. Откройте папку и запустите **`start-vscodium.cmd`**.
4. После загрузки редактора откройте терминал: `` Ctrl + ` `` или **Terminal → New Terminal**.

## Если вы перенесли сборку

После перемещения папки `VSCodium-portable` в другое место:

- запустите **`configure-runtime.cmd`** заново и укажите папки Python/Java;
- запустите **`create-shortcuts.cmd`** заново, чтобы обновить ярлыки;
- перенесите личные файлы: `~/.ssh`, `~/.kube`, `~/.bash_aliases`, `config/pg_service.conf`, `config/pgpass`.

## Почему нельзя просто кликать `VSCodium.exe`

Если запустить `VSCodium.exe` напрямую, редактор откроется, но встроенный терминал **не увидит MSYS2-утилиты**: `git`, `kubectl`, `helm`, `psql`, `ssh`, `jq` и другие.

Скрипт `start-vscodium.cmd` перед запуском прописывает нужные пути в `PATH`, поэтому терминал получает полноценное bash-окружение.

## Первая проверка

В терминале VSCodium выполните:

```bash
git --version
which git kubectl helm psql ssh curl jq bash
```

Если все команды найдены — всё настроено правильно.

## Настройка Python и Java

Python и Java не входят в сборку. Если они нужны:

1. Скопируйте готовые portable-папки Python и/или JDK на целевую машину.
2. Закройте VSCodium.
3. Запустите **`configure-runtime.cmd`**.
4. Выберите папки, нажмите **Test**, затем **Save**.
5. Снова запустите VSCodium через `start-vscodium.cmd`.

Подробнее:

- [Работа с Python](plugins/Python.md)
- Настройки Java описаны в `configure-runtime.cmd`.

## Создание ярлыков

Запустите **`create-shortcuts.cmd`**. Он создаст ярлыки:

- `VSCodium Ops Toolkit.lnk` — запуск редактора.
- `MSYS2 Bash.lnk` — отдельное окно MSYS2 Bash.
- `Configure Runtime.lnk` — настройка Python/Java.

После перемещения папки запустите `create-shortcuts.cmd` заново, чтобы пути в ярлыках обновились.

## Git внутри сборки

**Git входит в сборку** как часть MSYS2-окружения и работает в терминале VSCodium. Это **не** тот Git, который может быть установлен в Windows отдельно.

- Проверьте версию в терминале: `git --version`.
- Путь к Git: `which git` — должен выводить `/usr/bin/git` (внутри MSYS2 это `msys64/usr/bin/git`).
- Конфигурация Git хранится в `msys64/home/<имя_пользователя>/.gitconfig`.
- SSH-ключи Git использует из `msys64/home/<имя_пользователя>/.ssh/`.
- Git-плагины отсутствуют — используйте встроенную панель **Source Control** (`Ctrl+Shift+G`) или командную строку.

> ⚠️ **Будьте осторожны при передаче сборки другим людям.** Если вы скопировали в неё свои SSH-ключи (`~/.ssh/id_rsa`, `id_ed25519` и т.д.) или файл `~/.gitconfig` с личными данными, они окажутся внутри архива. Перед распространением проверьте папку `msys64/home/<имя_пользователя>/` и удалите оттуда чужие/личные ключи.

Если у вас уже есть Git для Windows (Git Bash) с настроенными ключами и `.gitconfig`, их придётся перенести вручную или заново настроить в MSYS2-окружении.

## Где что хранится

| Что | Где |
|---|---|
| Настройки VSCodium | `data/user-data/User/settings.json` |
| Расширения | `data/extensions/` |
| Bash/SSH/Git/kubectl конфиги | `msys64/home/<имя_пользователя>/` |
| PostgreSQL / Kubernetes конфиги | `config/` |
| Мануалы | `manual/` |

Личные файлы (`~/.ssh`, `~/.kube`, `~/.bash_aliases`, `.gitconfig`) не входят в архив — при переносе на другую машину переносите их отдельно.

## Если что-то пошло не так

| Симптом | Причина | Решение |
|---|---|---|
| В терминале не находятся `git`, `kubectl` | Запущен `VSCodium.exe` вместо `start-vscodium.cmd` | Закройте редактор и запустите `start-vscodium.cmd` |
| `git clone` падает с ошибкой DLL | MSYS2 PATH не в POSIX-формате | Убедитесь, что файл `msys64/etc/profile.d/vscodium-ops-toolkit.sh` содержит нормализацию PATH |
| Ошибка распаковки `Cannot create symbolic link` | Использован встроенный архиватор Windows | Распакуйте через 7-Zip |
| VSCodium не видит Python/Java | Путь не сохранён или папка переехала | Запустите `configure-runtime.cmd` заново |
| Предупреждение `could not find /tmp` | Отсутствует папка `/tmp` | Выполните `mkdir -p /tmp` в терминале |

## Что дальше

- [manual/README.md](README.md) — полный список мануалов.
- [plugins/Python.md](plugins/Python.md) — Python в VSCodium.
- [plugins/Kubernetes.md](plugins/Kubernetes.md) — Kubernetes, kubectl, helm.
- [plugins/PostgreSQL.md](plugins/PostgreSQL.md) — PostgreSQL и psql.
- [tools/ssh.md](tools/ssh.md) — SSH, ключи, туннели.
- [tools/kubectl.md](tools/kubectl.md) — kubectl.
