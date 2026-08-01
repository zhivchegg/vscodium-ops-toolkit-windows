# REST Client

Плагин для отправки HTTP-запросов прямо из редактора VSCodium. Удобен для проверки API без сторонних инструментов.

## Что проверить при инциденте

1. Отвечает ли сервис на health-эндпоинт?
2. Какой HTTP-код возвращается?
3. Есть ли задержки (timeout)?
4. Корректен ли JSON в теле запроса?

## Создание файла запросов

Создайте файл с расширением `.http` или `.rest`, например `api.http`:

```http
### Проверка доступности
GET http://localhost:8080/health

### GET с заголовками
GET http://localhost:8080/api/users
Authorization: Bearer {{token}}

### POST JSON
POST http://localhost:8080/api/events
Content-Type: application/json

{
    "level": "ERROR",
    "message": "timeout connecting to database"
}

### POST формы
POST http://localhost:8080/api/upload
Content-Type: application/x-www-form-urlencoded

name=server-01&status=active

### POST с файлом
POST http://localhost:8080/api/upload
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary

------WebKitFormBoundary
Content-Disposition: form-data; name="file"; filename="data.json"
Content-Type: application/json

< ./data.json
------WebKitFormBoundary--

### PUT
PUT http://localhost:8080/api/users/1
Content-Type: application/json

{
    "status": "inactive"
}

### DELETE
DELETE http://localhost:8080/api/users/1
```

## Отправка запроса

Над каждым блоком `###` появится ссылка `Send Request`. Нажмите её — ответ откроется в новой вкладке.

## Переменные окружения

В `settings.json`:

```json
{
    "rest-client.environmentVariables": {
        "$shared": {
            "host": "localhost"
        },
        "local": {
            "host": "localhost:8080",
            "token": "local-token"
        },
        "prod": {
            "host": "api.example.com",
            "token": "prod-token"
        }
    }
}
```

В запросе:

```http
GET http://{{host}}/health
Authorization: Bearer {{token}}
```

Переключение окружения: `Ctrl+Shift+P` → `REST Client: Switch Environment`.

## Глобальные настройки запроса

```http
# @timeout 30000
# @contentType application/json
GET http://{{host}}/slow-endpoint
```

## Сохранение ответа

Во вкладке результата нажмите иконку диска или правой кнопкой → `Save Response Body`.

## Практический пример: диагностика API

```http
### Health check
GET http://{{host}}/health

### Метрики (Prometheus)
GET http://{{host}}/metrics

### Логи приложения (если доступны)
GET http://{{host}}/actuator/logfile

### Проверка с таймаутом
# @timeout 5000
GET http://{{host}}/api/status
```

## Полезные советы

- Для файлов используйте `< /path/to/file.json` в теле запроса.
- Графический вывод JSON с подсветкой синтаксиса.
- Можно отправлять GraphQL-запросы через `Content-Type: application/json`.

## Подводные камни

- Не коммитьте файлы `.http` с реальными токенами.
- REST Client не умеет повторять запросы автоматически — для нагрузочного теста используйте curl или wrk.
- localhost в Windows может разрешаться в IPv6 — при проблемах пробуйте `127.0.0.1`.
- Директивы `@timeout` и `@contentType` должны быть в начале запроса.
