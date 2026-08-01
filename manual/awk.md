# awk

Обработка текстовых данных по столбцам и простые вычисления.

## Основные примеры

```bash
# Вывести первый и третий столбец
awk '{print $1, $3}' app.log

# Указать разделитель (например, запятая)
awk -F',' '{print $2}' data.csv

# Фильтр по значению столбца
awk '$3 == "ERROR" {print $0}' app.log

# Сравнение чисел
awk '$2 > 500 {print $1, $2}' app.log
```

## Подсчёты

```bash
# Количество строк
awk 'END {print NR}' app.log

# Количество строк с паттерном
awk '/ERROR/ {n++} END {print n}' app.log

# Сумма по столбцу
awk '{sum += $2} END {print sum}' app.log

# Среднее значение
awk '{sum += $2; n++} END {print sum/n}' app.log
```

## Группировка

```bash
# Подсчёт вхождений по столбцу
awk '{count[$3]++} END {for (k in count) print count[k], k}' app.log

# Сумма по группе
awk '{sum[$1] += $2} END {for (k in sum) print k, sum[k]}' app.log
```

## Полезные переменные

```bash
# NR — номер строки, NF — количество полей
awk '{print NR ": " $0}' app.log
awk 'NF > 5 {print $0}' app.log
```
