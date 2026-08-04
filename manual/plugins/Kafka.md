# Kafka

Плагин Kafka for VS Code помогает просматривать брокеры, топики, партиции и сообщения.

## Что проверить при инциденте

1. Доступны ли брокеры?
2. Есть ли топики с аномальным lag у consumer groups?
3. Не переполнены ли диски брокеров?
4. Равномерно ли распределены партиции?
5. Нет ли offline-реплик?

## Подключение к кластеру

1. Откройте панель Kafka (`Ctrl+Shift+P` → `Kafka: Focus on Kafka Explorer`).
2. Нажмите "Add Cluster".
3. Укажите адрес брокеров, например `localhost:9092`.
4. При необходимости укажите SASL/SSL настройки.

## Просмотр сообщений

В панели Kafka:
- разверните кластер → топики → нужный топик
- правый клик на партиции → `Start Consumer`
- сообщения появятся в панели вывода

## Быстрые проверки в терминале

```bash
# Список топиков
kafka-topics.sh --bootstrap-server localhost:9092 --list

# Информация о топике
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic events

# Lag consumer groups
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --all-groups --describe

# Описание группы
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group events-consumer

# Отправить тестовое сообщение
echo '{"event":"test"}' | kafka-console-producer.sh --broker-list localhost:9092 --topic events

# Прочитать сообщения
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic events --from-beginning --max-messages 10
```

> **Примечание:** пути к скриптам `kafka-*` должны быть в PATH. В данной сборке они не включены — используйте клиентский инструментарий вашего Kafka-дистрибутива.

## Установка Kafka CLI в сборку

Если нужны консольные утилиты Kafka (`kafka-topics.sh`, `kafka-console-consumer.sh`, `kafka-consumer-groups.sh` и др.), добавьте их вручную:

1. На машине с интернетом скачайте бинарный дистрибутив:
   - Страница загрузок: https://kafka.apache.org/downloads
   - Репозиторий исходников: https://github.com/apache/kafka
2. Распакуйте архив.
3. Скопируйте папку внутрь сборки, например:
   ```text
   VSCodium-portable/tools/kafka/
   ```
4. Убедитесь, что путь к скриптам добавлен в PATH. Проверьте в терминале:
   ```bash
   ls VSCodium-portable/tools/kafka/bin/kafka-topics.sh
   export PATH="/c/Users/Евгений/Documents/vscodium/VSCodium-portable/tools/kafka/bin:$PATH"
   kafka-topics.sh --version
   ```

> **Важно:** Kafka CLI написаны на Scala/Java и требуют локальной JDK. Подключите JDK через `configure-runtime.cmd`, прежде чем использовать `kafka-topics.sh`.

Для удобства можно сделать путь к `tools/kafka/bin` постоянным через `~/.bash_aliases`:

```bash
alias kafka-topics='VSCodium-portable/tools/kafka/bin/kafka-topics.sh'
alias kafka-console-consumer='VSCodium-portable/tools/kafka/bin/kafka-console-consumer.sh'
alias kafka-consumer-groups='VSCodium-portable/tools/kafka/bin/kafka-consumer-groups.sh'
```

## Диагностика lag и перегрузки

```bash
# Группы с задержкой
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --all-groups --describe | grep -v "0               0"

# Пример вывода:
# GROUP           TOPIC     PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG  CONSUMER-ID
# events-consumer events    0          1000            5000            4000 consumer-1
```

Если LAG растёт:
- проверьте скорость обработки consumer'ов
- увеличьте количество consumer'ов в группе (не больше числа партиций)
- проверьте, нет ли ошибок в логах consumer'ов

## Проверка состояния брокеров

```bash
# Проверка доступности брокера
nc -zv kafka-broker 9092

# Проверка TLS
openssl s_client -connect kafka-broker:9093 -servername kafka-broker </dev/null

# DNS
nslookup kafka-broker
```

## Подводные камни

- `__consumer_offsets` — системный топик, не удаляйте его.
- Producer может работать, а consumer отставать — отслеживайте LAG.
- Сообщения с ключом всегда попадают в одну и ту же партицию.
- Число consumer'ов в группе не может превышать число партиций — лишние consumer'ы будут простаивать.
- Если брокер падает с `No space left on device`, операции записи останавливаются.
