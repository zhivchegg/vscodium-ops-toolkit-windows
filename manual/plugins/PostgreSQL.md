# PostgreSQL

Плагин `ckolkman.vscode-postgres` позволяет подключаться к базам, просматривать таблицы и выполнять запросы.

## Что проверить при инциденте

1. Доступен ли сервер PostgreSQL по сети?
2. Правильны ли логин/пароль и имя базы?
3. Нет ли блокировок и долгих запросов?
4. Сколько места занимают таблицы?

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

## Диагностические запросы

```sql
-- Список баз данных
SELECT datname FROM pg_database WHERE datistemplate = false;

-- Активные запросы и их состояние
SELECT pid, usename, state, query_start, wait_event, query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;

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

-- Медленные запросы (если включён pg_stat_statements)
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```

## Проверка связности

```bash
# Порт
nc -zv db-host 5432

# TLS
openssl s_client -connect db-host:5432 -starttls postgres </dev/null
```

## Подводные камни

- `LIMIT` обязателен для больших таблиц.
- Для production включайте SSL/TLS.
- Не храните пароли в запросах, которые попадают в лог.
- Long-running query может заблокировать DDL-операции.
