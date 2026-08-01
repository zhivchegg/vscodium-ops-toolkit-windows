# PostgreSQL

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

Создавайте подключения с понятными именами:
- `prod-db-primary`
- `prod-db-replica`
- `test-db`
- `dev-db`

## Примеры запросов

```sql
-- Список баз данных
SELECT datname FROM pg_database WHERE datistemplate = false;

-- Список таблиц
SELECT * FROM pg_tables WHERE schemaname = 'public';

-- Структура таблицы
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users';

-- Поиск по таблице
SELECT * FROM users WHERE email LIKE '%@example.com' LIMIT 10;

-- Размер таблиц
SELECT relname AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

-- Активные запросы
SELECT pid, state, query_start, query
FROM pg_stat_activity
WHERE state = 'active';
```

## psql в терминале

Если установлен psql:

```bash
psql -h localhost -U postgres -d mydb
```

## Советы

- Для production включайте SSL/TLS в настройках подключения.
- Группируйте коннекты по окружениям.
- Используйте `LIMIT` для больших таблиц.
