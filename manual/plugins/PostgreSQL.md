# PostgreSQL

Плагин `ckolkman.vscode-postgres` позволяет подключаться к базам, просматривать таблицы и выполнять запросы.

## Что проверить при инциденте

1. Доступен ли сервер PostgreSQL по сети?
2. Правильны ли логин/пароль и имя базы?
3. Нет ли блокировок и долгих запросов?
4. Сколько места занимают таблицы?
5. Работает ли репликация?

## Создание подключения

1. Откройте боковую панель PostgreSQL (иконка слона).
2. Нажмите `+` / `New Connection`.
3. Заполните:
   - Host: `localhost` или IP сервера
   - Port: `5432`
   - Database: `postgres`
   - Username: `postgres`
   - Password: пароль
4. Нажмите `Save`.

## Организация коннектов

Плагин не поддерживает папки для группировки. Используйте понятные префиксы в именах:

```
PROD-db-primary
PROD-db-replica
TEST-db
dev-local
```

Для большого количества хостов рекомендуется:
- вести отдельный список подключений в `connections.md`
- использовать psql и `.pgpass` для автоматизации
- хранить connection string в переменных окружения

## psql в терминале

Более удобный способ при работе с множеством хостов:

```bash
# Подключение по строке
psql "postgresql://user:pass@host:5432/dbname?sslmode=require"

# Использование переменной окружения
export PGPASSWORD="secret"
psql -h prod-db.example.com -U postgres -d mydb

# Файл паролей ~/.pgpass (права 600)
# host:port:database:user:password
prod-db.example.com:5432:*:postgres:secret
```

### Портативные настройки подключений `PGSERVICEFILE` и `PGPASSFILE`

В сборке настроено автоопределение файлов сервисов и паролей, если они лежат внутри `VSCodium-portable/config/`:

- `config/pg_service.conf` — описания подключений (имя сервиса, хост, порт, база).
- `config/pgpass` — пароли (права 600).

Если переменные `PGSERVICEFILE` и `PGPASSFILE` не заданы извне, MSYS2-профиль автоматически выставит их на эти файлы при наличии.

Пример `config/pg_service.conf`:

```ini
[prod-primary]
host=prod-db.example.com
port=5432
dbname=mydb
user=postgres
sslmode=require

[test-local]
host=localhost
port=5432
dbname=testdb
user=postgres
```

Пример `config/pgpass`:

```text
prod-db.example.com:5432:*:postgres:secret
test-local:5432:*:postgres:testpass
```

Подключение по сервису:

```bash
psql service=prod-primary
```

> **Важно:** файл `config/pgpass` содержит пароли — не добавляйте его в git. Для защиты можно хранить `config/` вне репозитория или использовать `.gitignore`.

## Диагностические запросы

```sql
-- Список баз данных
SELECT datname FROM pg_database WHERE datistemplate = false;

-- Активные запросы и их состояние
SELECT pid, usename, state, query_start, wait_event, query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;

-- Долгие запросы (больше 5 минут)
SELECT pid, usename, query_start, query
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 minutes';

-- Блокировки
SELECT blocked_locks.pid AS blocked_pid,
       blocking_locks.pid AS blocking_pid,
       blocked_activity.query AS blocked_query,
       blocking_activity.query AS blocking_query
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- Размер таблиц
SELECT relname AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 20;

-- Размер баз данных
SELECT datname,
       pg_size_pretty(pg_database_size(datname)) AS size
FROM pg_database
ORDER BY pg_database_size(datname) DESC;

-- Медленные запросы (если включён pg_stat_statements)
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;

-- Состояние репликации
SELECT * FROM pg_stat_replication;
```

## Проверка связности

```bash
# Порт
nc -zv db-host 5432

# TLS
openssl s_client -connect db-host:5432 -starttls postgres </dev/null
```

## Резервное копирование и восстановление

```bash
# Дамп базы
pg_dump -h db-host -U postgres -d mydb > mydb.sql

# Дамп в сжатом виде
pg_dump -h db-host -U postgres -d mydb | gzip > mydb.sql.gz

# Восстановление
psql -h db-host -U postgres -d mydb < mydb.sql

# Только схема
pg_dump -h db-host -U postgres -d mydb --schema-only > mydb-schema.sql
```

## Обслуживание

```sql
-- Сбор статистики для планировщика
ANALYZE;

-- Очистка и освобождение места
VACUUM FULL my_table;  -- блокирует таблицу!

-- Обычная очистка без блокировки
VACUUM my_table;
```

## Подводные камни

- `LIMIT` обязателен для больших таблиц.
- Для production включайте SSL/TLS.
- Не храните пароли в запросах, которые попадают в лог.
- Long-running query может заблокировать DDL-операции.
- `VACUUM FULL` блокирует таблицу — запускайте в окно обслуживания.
- `pg_stat_statements` требует расширения: `CREATE EXTENSION pg_stat_statements;`.
