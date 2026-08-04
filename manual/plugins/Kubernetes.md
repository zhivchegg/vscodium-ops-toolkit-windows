# Kubernetes

Плагин Kubernetes Tools помогает редактировать YAML-манифесты: автодополнение, валидация схемы, hover-документация.

> **Офлайн-режим:** сборка настроена для работы без интернета. `yaml.schemaStore.enable` и `yaml.kubernetesCRDStore.enable` отключены — плагин не будет пытаться загружать схемы из интернета. Автодополнение и валидация базовых Kubernetes-ресурсов работают локально за счёт встроенных схем.

## Что проверить при инциденте

1. Какой контекст kubectl активен?
2. Все ли поды в статусе Running?
3. Есть ли события типа Warning или ошибки?
4. Не перезапускаются ли контейнеры (CrashLoopBackOff)?
5. Достаточно ли ресурсов (CPU, память, место на диске)?
6. Работают ли метрики (`kubectl top`)?

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

# Подробная информация о нодах
kubectl get nodes -o wide

# Поды во всех неймспейсах
kubectl get pods -A

# События с сортировкой по времени
kubectl get events --sort-by='.lastTimestamp' -A

# Только Warning-события
kubectl get events --field-selector type=Warning -A --sort-by='.lastTimestamp'

# Поды с проблемами
kubectl get pods -A --field-selector=status.phase!=Running

# Метрики (если установлен metrics-server)
kubectl top nodes
kubectl top pods -A
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
| `Evicted` | Нехватка диска или памяти на ноде | `kubectl describe pod` |

## Helm

Helm-функциональность встроена в плагин Kubernetes Tools. Поддерживаются:
- подсветка Helm-шаблонов
- автодополнение функций Helm/Sprig/Go templates
- сниппеты для создания чартов
- команды через палитру (`Ctrl+Shift+P` → `Helm: ...`)

### Частые команды Helm

```bash
# Создать чарт
helm create mychart

# Установить релиз
helm install my-release ./mychart

# Обновить релиз
helm upgrade my-release ./mychart

# Установить или обновить
helm upgrade --install my-release ./mychart

# Просмотреть сгенерированные манифесты без установки
helm template my-release ./mychart

# Проверить чарт на ошибки
helm lint ./mychart

# Список релизов
helm list -A

# История релиза
helm history my-release -n my-ns

# Откат к предыдущей версии
helm rollback my-release 1 -n my-ns

# Удалить релиз
helm uninstall my-release -n my-ns
```

### Диагностика Helm-релиза

```bash
# Почему релиз не обновился
helm status my-release -n my-ns

# Последние события подов релиза
kubectl get events -n my-ns --field-selector reason=FailedMount

# Сравнить установленный релиз с чартом
helm get values my-release -n my-ns
helm get manifest my-release -n my-ns | less
```

### Подводные камни Helm

- `helm upgrade` не удаляет ресурсы, которые были в прошлой версии чарта, но убраны в новой.
- `helm rollback` не откатывает изменения, внесённые вручную через `kubectl edit`.
- Большие чарты с множеством шаблонов сложно отлаживать — используйте `helm template` для проверки.
- Храните `values.yaml` для каждого окружения в Git.

## Проброс портов и логи нескольких подов

```bash
# Проброс порта пода
kubectl port-forward deploy/my-app 8080:80 -n default

# Логи всех подов деплоя
kubectl logs -l app=my-app -n default --tail 100 -f

# Логи по метке и фильтр ошибок
kubectl logs -l app=my-app -n default --tail 500 | err
```

## Подводные камни

- Всегда проверяйте текущий контекст перед операциями на production.
- `kubectl apply` обновляет только указанные поля — удалённые поля в манифесте не удалятся в кластере автоматически.
- `kubectl delete` необратим — для критичных ресурсов используйте `--dry-run=client`.
- При пробросе порта соединение держится на вашей машине — если вы отключитесь, порт закроется.
- `kubectl top` требует установленного metrics-server.
