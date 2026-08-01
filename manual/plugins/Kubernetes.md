# Kubernetes

Плагин Kubernetes Tools помогает редактировать YAML-манифесты: автодополнение, валидация схемы, hover-документация.

## Что проверить при инциденте

1. Какой контекст kubectl активен?
2. Все ли поды в статусе Running?
3. Есть ли события типа Warning или ошибки?
4. Не перезапускаются ли контейнеры (CrashLoopBackOff)?
5. Достаточно ли ресурсов (CPU, память, место на диске)?

## Подключение к кластеру

kubectl читает конфигурацию из файла `~/.kube/config`. Если у вас есть несколько кластеров:

```bash
# Список контекстов
kubectl config get-contexts

# Текущий контекст
kubectl config current-context

# Переключиться
kubectl config use-context prod
```

Если кластер новый и конфига нет:

```bash
mkdir -p ~/.kube
cp /path/to/cluster-config ~/.kube/config
kubectl config use-context <context-name>
```

## Быстрые проверки состояния

```bash
# Общая информация о кластере
kubectl cluster-info

# Ноды
kubectl get nodes

# Поды во всех неймспейсах
kubectl get pods -A

# События с сортировкой по времени
kubectl get events --sort-by='.lastTimestamp' -A

# Поды с проблемами
kubectl get pods -A --field-selector=status.phase!=Running
```

## Диагностика пода

```bash
POD=my-pod
NS=default

# Описание и события
kubectl describe pod "$POD" -n "$NS"

# Логи
kubectl logs "$POD" -n "$NS" --tail 200

# Логи предыдущего контейнера (после перезапуска)
kubectl logs "$POD" -n "$NS" --previous

# Внутрь пода
kubectl exec -it "$POD" -n "$NS" -- sh

# Проброс порта для проверки
kubectl port-forward "$POD" -n "$NS" 8080:80
```

## Проверка манифеста без применения

```bash
# Клиентская проверка
kubectl apply --dry-run=client -f deployment.yaml

# Проверка на сервере
kubectl apply --dry-run=server -f deployment.yaml

# Объяснение полей
kubectl explain deployment.spec.strategy
```

## Типовые проблемы

| Симптом | Причина | Диагностика |
|---|---|---|
| `ImagePullBackOff` | Не удалось скачать образ | `kubectl describe pod` → Events |
| `CrashLoopBackOff` | Контейнер падает после старта | `kubectl logs --previous` |
| `Pending` | Нет ресурсов или taint | `kubectl describe node` |
| `OOMKilled` | Нехватка памяти | `kubectl describe pod` → Last State |
| `CreateContainerConfigError` | Проблема с secret/configmap | `kubectl describe pod` |

## Проброс портов и логи нескольких подов

```bash
# Проброс порта пода
kubectl port-forward deploy/my-app 8080:80 -n default

# Логи всех подов деплоя
kubectl logs -l app=my-app -n default --tail 100 -f

# Логи по метке и фильтр ошибок
kubectl logs -l app=my-app -n default --tail 500 | err
```
