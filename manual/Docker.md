# Docker

Плагин Docker показывает образы, контейнеры, тома и сети в боковой панели.

## Основные команды

```bash
# Список запущенных контейнеров
docker ps

# Все контейнеры
docker ps -a

# Образы
docker images

# Логи
docker logs -f container_name

# Выполнить команду внутри контейнера
docker exec -it container_name /bin/sh

# Статистика
docker stats

# Остановить и удалить контейнер
docker stop container_name
docker rm container_name

# Удалить образ
docker rmi image_id

# Сборка образа
docker build -t myapp:1.0 .

# Запуск контейнера
docker run -d -p 8080:80 --name myapp myapp:1.0
```

## Очистка

```bash
# Удалить остановленные контейнеры
docker container prune

# Удалить неиспользуемые образы
docker image prune

# Удалить всё неиспользуемое
docker system prune
```

## Пример Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

## Просмотр логов нескольких контейнеров

```bash
docker logs -f container1 &
docker logs -f container2 &
```
