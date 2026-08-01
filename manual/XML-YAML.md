# XML и YAML

## XML (Red Hat)

- Автодополнение тегов.
- Валидация по XSD.
- Форматирование: `Shift + Alt + F`.

Пример:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
    <server host="localhost" port="8080"/>
</config>
```

## YAML (Red Hat)

- Автодополнение для Kubernetes, docker-compose, Ansible.
- Поддержка custom tags CloudFormation (уже настроены в `settings.json`).
- Проверка синтаксиса.

Пример Kubernetes Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
```

## CloudFormation custom tags

В `settings.json` уже добавлены:

```json
"yaml.customTags": [
    "!And", "!If", "!Not", "!Equals", "!Or",
    "!FindInMap sequence", "!FindInMap mapping",
    "!Sub", "!GetAtt", "!GetAZs", "!ImportValue",
    "!Select", "!Split", "!Join sequence"
]
```

## Форматирование

`Ctrl + Shift + P` → `Format Document` или `Shift + Alt + F`.
