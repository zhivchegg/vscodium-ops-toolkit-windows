# REST Client

Плагин для отправки HTTP-запросов прямо из редактора VSCodium.

## Создание файла запросов

Создайте файл с расширением `.http` или `.rest`, например `api.http`:

```http
### Проверка доступности
GET https://httpbin.org/get

### GET с заголовками
GET https://httpbin.org/bearer
Authorization: Bearer YOUR_TOKEN_HERE

### POST JSON
POST https://httpbin.org/post
Content-Type: application/json

{
    "name": "server-01",
    "status": "active",
    "tags": ["prod", "web"]
}

### POST формы
POST https://httpbin.org/post
Content-Type: application/x-www-form-urlencoded

name=server-01&status=active

### PUT
PUT https://httpbin.org/put
Content-Type: application/json

{
    "id": 1,
    "status": "inactive"
}

### DELETE
DELETE https://httpbin.org/delete
```

## Отправка запроса

Над каждым блоком `###` появится ссылка `Send Request`. Нажмите её — ответ откроется в новой вкладке.

## Переменные окружения

В настройках VSCodium (`settings.json`):

```json
{
    "rest-client.environmentVariables": {
        "$shared": {
            "host": "localhost"
        },
        "local": {
            "host": "localhost:8080"
        },
        "prod": {
            "host": "api.example.com"
        }
    }
}
```

В запросе:

```http
GET http://{{host}}/health
```

Переключение окружения: `Ctrl + Shift + P` → `REST Client: Switch Environment`.

## Сохранение ответа

Во вкладке результата нажмите иконку диска или правой кнопкой → `Save Response Body`.

## Практический пример

```http
### Получить список пользователей
GET http://localhost:8080/api/users
Authorization: Bearer {{token}}

### Создать пользователя
POST http://localhost:8080/api/users
Content-Type: application/json

{
    "username": "admin",
    "email": "admin@example.com"
}
```

## Полезные советы

- Для локальных сервисов используйте `http://localhost:8080/api/...`.
- Можно отправлять файлы через `@path/to/file.json` в теле запроса.
- Графический вывод JSON с подсветкой синтаксиса в ответе.
