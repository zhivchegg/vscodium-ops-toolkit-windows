# Kubernetes

Плагин Kubernetes Tools помогает редактировать YAML-манифесты: автодополнение, валидация схемы, hover-документация.

## kubectl в терминале

```bash
# Проверить версию
kubectl version --client

# Информация о кластере
kubectl cluster-info

# Список нод
kubectl get nodes

# Список подов
kubectl get pods -A
kubectl get pods -n default

# Подробная информация о поде
kubectl describe pod pod-name -n default

# Логи пода
kubectl logs pod-name
kubectl logs -f pod-name

# Логи предыдущего контейнера
kubectl logs pod-name --previous

# Выполнить команду внутри пода
kubectl exec -it pod-name -- /bin/sh

# Применить манифест
kubectl apply -f deployment.yaml

# Проверить манифест без применения
kubectl apply --dry-run=client -f deployment.yaml

# Проброс порта
kubectl port-forward pod-name 8080:80

# Удалить ресурс
kubectl delete -f deployment.yaml
```

## Пример Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

## Пример Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
  type: ClusterIP
```

## Полезные советы

- Используйте `kubectl explain deployment.spec` для документации полей.
- Для переключения между кластерами: `kubectl config use-context context-name`.
- Просмотр событий: `kubectl get events --sort-by='.lastTimestamp'`.
