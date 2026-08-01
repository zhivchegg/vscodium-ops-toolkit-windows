# curl

HTTP-запросы из командной строки. Незаменим для проверки API, загрузки файлов и отладки сетевых проблем.

## Что проверить при инциденте

1. Отвечает ли сервис?
2. Какой HTTP-код возвращается?
3. Есть ли редиректы?
4. Сколько длится ответ (latency)?
5. Корректны ли заголовки?

## Основные примеры

```bash
# GET-запрос
curl https://api.example.com/status

# Сохранить в файл
curl -o status.json https://api.example.com/status

# Следовать редиректам
curl -L https://example.com

# Показать только заголовки ответа
curl -I https://example.com

# Показать полный обмен (запрос + ответ)
curl -v https://api.example.com/status
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

## Мониторинг и диагностика

```bash
# Только HTTP-код
curl -s -o /dev/null -w "%{http_code}" https://api.example.com/status

# Время выполнения запроса
curl -s -o /dev/null -w "time_total: %{time_total}s\n" https://api.example.com/status

# Проверка TLS-сертификата
curl -vI https://api.example.com 2>&1 | grep -E "subject:|issuer:|expire date:"

# Игнорировать ошибки сертификата (только для отладки!)
curl -k https://self-signed.example.com
```

## Практический пример: проверка health-чеков

```bash
#!/bin/bash
URL="https://api.example.com/health"
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
TIME=$(curl -s -o /dev/null -w "%{time_total}" "$URL")

if [ "$CODE" != "200" ]; then
    echo "ERROR: $URL returned $CODE"
    exit 1
fi

echo "OK: $URL returned $CODE in ${TIME}s"
```

## Подводные камни

- По умолчанию curl не следует за редиректами — используйте `-L`.
- `-d` отправляет `Content-Type: application/x-www-form-urlencoded`, для JSON укажите заголовок явно.
- Для бинарных файлов используйте `-o` или `-O`, иначе вывод испортит терминал.
- В Windows/MSYS2 пути с обратными слешами в `@file` могут работать некорректно — используйте прямые слеши.
