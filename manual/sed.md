# sed

Потоковый редактор для замены, удаления и извлечения текста.

## Замена текста

```bash
# Простая замена в файле
sed 's/foo/bar/' app.log

# Замена всех вхождений в строке
sed 's/foo/bar/g' app.log

# Замена с учётом регистра (по умолчанию)
sed 's/Error/ERROR/g' app.log

# Замена без учёта регистра
sed 's/error/ERROR/gi' app.log

# Замена только в строках, содержащих паттерн
sed '/ERROR/s/foo/bar/g' app.log
```

## Удаление строк

```bash
# Удалить пустые строки
sed '/^$/d' app.log

# Удалить строки с паттерном
sed '/DEBUG/d' app.log

# Удалить строки 1–10
sed '1,10d' app.log
```

## Извлечение строк

```bash
# Вывести строки 5–20
sed -n '5,20p' app.log

# Вывести строки с паттерном
sed -n '/ERROR/p' app.log

# Вывести последние 20 строк (аналог tail)
sed -n '$p' app.log
```

## Редактирование файла на месте

```bash
# Создать резервную копию .bak
sed -i.bak 's/foo/bar/g' app.log

# Без резервной копии
sed -i 's/foo/bar/g' app.log
```

## Комбинации

```bash
# Убрать ANSI-цвета
sed 's/\x1b\[[0-9;]*m//g' app.log

# Заменить разделитель, если в паттерне есть /
sed 's#C:/Users/foo#D:/data#g' app.log
```
