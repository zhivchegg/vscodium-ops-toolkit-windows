# XML и YAML

## XML (Red Hat)

Плагин Red Hat XML предоставляет:
- автодополнение тегов
- валидацию по XSD/DTD
- форматирование
- навигацию по XPath

### Пример

```xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
    <server host="localhost" port="8080"/>
</config>
```

### Форматирование

`Shift + Alt + F` или `Ctrl+Shift+P` → `Format Document`.

### Валидация по XSD

Если в XML указана схема, плагин проверит соответствие автоматически:

```xml
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="config.xsd">
```

## YAML (Red Hat)

Плагин Red Hat YAML предоставляет:
- автодополнение для Kubernetes, docker-compose, Ansible
- проверку синтаксиса
- поддержку custom tags CloudFormation

### Пример Kubernetes Service

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

### CloudFormation custom tags

В `settings.json` уже добавлены:

```json
"yaml.customTags": [
    "!And", "!If", "!Not", "!Equals", "!Or",
    "!FindInMap sequence", "!FindInMap mapping",
    "!Sub", "!GetAtt", "!GetAZs", "!ImportValue",
    "!Select", "!Split", "!Join sequence"
]
```

### Проверка YAML в терминале

```bash
# Проверить синтаксис через Python
python -c "import yaml; yaml.safe_load(open('file.yaml'))"

# Проверить Kubernetes-манифест
kubectl apply --dry-run=client -f file.yaml
```

## Подводные камни

- В YAML табы запрещены — используйте пробелы.
- Отступы в YAML критичны: обычно 2 пробела.
- Спецсимволы в строках (`:`, `{`, `}`, `[`, `]`, `,`, `&`, `*`, `!`, `|`, `>`, `'`, `"`, `#`, `%`, `@`, `` ` ``) могут требовать кавычек.
- XML без BOM и с правильной кодировкой меньше вызывает проблем при парсинге.
