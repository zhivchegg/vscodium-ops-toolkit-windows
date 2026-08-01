# curl

HTTP-запросы из командной строки.

## Основные примеры

```bash
# GET-запрос
curl https://api.example.com/status

# Сохранить в файл
curl -o status.json https://api.example.com/status

# Следовать редиректам
curl -L https://example.com

# Показать заголовки ответа
curl -I https://example.com
```

## POST и данные

```bash
# Отправить JSON
curl -X POST https://api.example.com/events \
  -H "Content-Type: application/json" \
  -d '{"level":"ERROR","message":"timeout"}'

# Отправить форму
curl -X POST https://api.example.com/upload \
  -F "file=@app.log" \
  -F "name=app"

# Данные из файла
curl -X POST https://api.example.com/events \
  -H "Content-Type: application/json" \
  -d @event.json
```

## Аутентификация

```bash
# Basic Auth
curl -u user:password https://api.example.com/private

# Bearer-токен
curl -H "Authorization: Bearer $TOKEN" https://api.example.com/private
```

## Отладка

```bash
# Показать полный обмен (запрос + ответ)
curl -v https://api.example.com/status

# Только HTTP-код
curl -s -o /dev/null -w "%{http_code}" https://api.example.com/status
```
