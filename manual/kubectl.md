# kubectl

Управление Kubernetes-кластером из командной строки.

## Основные команды

```bash
# Проверить подключение к кластеру
kubectl cluster-info

# Список нод
kubectl get nodes

# Список подов
kubectl get pods

# Список подов во всех неймспейсах
kubectl get pods -A

# Подробная информация о ресурсе
kubectl describe pod my-pod
```

## Работа с подами

```bash
# Логи пода
kubectl logs my-pod

# Логи с отслеживанием
kubectl logs -f my-pod

# Логи предыдущего контейнера (после перезапуска)
kubectl logs my-pod --previous

# Выполнить команду в поде
kubectl exec my-pod -- ls /app

# Интерактивная оболочка в поде
kubectl exec -it my-pod -- sh
```

## Ресурсы и неймспейсы

```bash
# Переключить неймспейс по умолчанию
kubectl config set-context --current --namespace=my-ns

# Получить все ресурсы в неймспейсе
kubectl get all -n my-ns

# Применить манифест
kubectl apply -f deployment.yaml

# Удалить ресурс
kubectl delete -f deployment.yaml
```

## Конфигурация

```bash
# Показать текущий контекст
kubectl config current-context

# Список контекстов
kubectl config get-contexts

# Переключить контекст
kubectl config use-context prod
```
