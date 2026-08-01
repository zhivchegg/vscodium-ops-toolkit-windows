# kubectl

Управление Kubernetes-кластером из командной строки.

## Что проверить при инциденте

1. Подключены ли мы к правильному кластеру?
2. Все ли ноды Ready?
3. Есть ли поды в статусе Error/CrashLoopBackOff/Pending?
4. Какие события произошли недавно?
5. Не закончились ли ресурсы (CPU, память, диск)?

## Подключение к кластеру

kubectl читает конфигурацию из файла `~/.kube/config`. В MSYS2 путь будет `~/.kube/config` (= `/home/<user>/.kube/config`).

### Получение конфигурации

Обычно конфиг выдаёт администратор кластера или скачивается из панели управления:

```bash
mkdir -p ~/.kube
cp /path/to/kubeconfig ~/.kube/config
chmod 600 ~/.kube/config
```

### Управление контекстами

```bash
# Список контекстов
kubectl config get-contexts

# Текущий контекст
kubectl config current-context

# Переключиться на production
kubectl config use-context prod

# Переключить неймспейс по умолчанию
kubectl config set-context --current --namespace=my-app
```

### Проверка подключения

```bash
kubectl cluster-info
kubectl get nodes
kubectl version --short
```

## Быстрые проверки состояния

```bash
# Поды во всех неймспейсах
kubectl get pods -A

# Поды с проблемами
kubectl get pods -A --field-selector=status.phase!=Running

# События с сортировкой по времени
kubectl get events --sort-by='.lastTimestamp' -A

# Все ресурсы в неймспейсе
kubectl get all -n my-ns
```

## Диагностика пода

```bash
POD=my-pod
NS=default

# Описание и события
kubectl describe pod "$POD" -n "$NS"

# Логи
kubectl logs "$POD" -n "$NS" --tail 200

# Логи предыдущего контейнера
kubectl logs "$POD" -n "$NS" --previous

# Интерактивная оболочка
kubectl exec -it "$POD" -n "$NS" -- sh

# Проброс порта
kubectl port-forward "$POD" -n "$NS" 8080:80
```

## Работа с несколькими подами

```bash
# Логи всех подов по метке
kubectl logs -l app=my-app -n default --tail 100 -f

# Логи с фильтром ошибок
kubectl logs -l app=my-app -n default --tail 500 | err
```

## Ресурсы

```bash
# Применить манифест
kubectl apply -f deployment.yaml

# Проверка без применения
kubectl apply --dry-run=client -f deployment.yaml

# Удалить ресурс
kubectl delete -f deployment.yaml

# Объяснение полей
kubectl explain deployment.spec.strategy
```

## Типовые проблемы

| Статус | Причина | Действие |
|---|---|---|
| `ImagePullBackOff` | Не найден образ | `kubectl describe pod` → Events |
| `CrashLoopBackOff` | Контейнер падает | `kubectl logs --previous` |
| `Pending` | Нет ресурсов | `kubectl describe node` |
| `OOMKilled` | Нехватка памяти | Увеличить limits или найти утечку |
| `CreateContainerConfigError` | Ошибка в secret/configmap | `kubectl describe pod` |

## Подводные камни

- Всегда проверяйте текущий контекст перед операциями на production.
- `kubectl apply` обновляет только указанные поля — удалённые поля в манифесте не удалятся в кластере автоматически.
- `kubectl delete` необратим — для критичных ресурсов используйте `--dry-run=client`.
- При пробросе порта соединение держится на вашей машине — если вы отключитесь, порт закроется.
