# Kafka

Плагин Kafka for VS Code помогает просматривать брокеры, топики, партиции и сообщения.

## Что проверить при инциденте

1. Доступны ли брокеры?
2. Есть ли топики с аномальным lag у consumer groups?
3. Не переполнены ли диски брокеров?
4. Равномерно ли распределены партиции?

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

# Отправить тестовое сообщение
echo '{"event":"test"}' | kafka-console-producer.sh --broker-list localhost:9092 --topic events

# Прочитать сообщения
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic events --from-beginning --max-messages 10
```

> **Примечание:** пути к скриптам `kafka-*` должны быть в PATH. В данной сборке они не включены — используйте клиентский инструментарий вашего Kafka-дистрибутива.

## Диагностика lag

```bash
# Группы с задержкой
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --all-groups --describe | grep -v "0               0"

# Пример вывода:
# GROUP           TOPIC     PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG  CONSUMER-ID
# events-consumer events    0          1000            5000            4000 consumer-1
```

Если LAG растёт:
- проверьте скорость обработки consumer'ов
- увеличьте количество consumer'ов в группе
- проверьте, нет ли ошибок в логах consumer'ов

## Подводные камни

- `__consumer_offsets` — системный топик, не удаляйте его.
- Producer может работать, а consumer отставать — отслеживайте LAG.
- Сообщения с ключом всегда попадают в одну и ту же партицию.
