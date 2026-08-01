# Git: GitLens, Git Graph, Git History

## GitLens

- Наведите на строку кода — увидите автора, дату и сообщение коммита.
- Панель `Source Control` (`Ctrl + Shift + G`) — статус изменений.
- `Ctrl + Shift + P` → `GitLens: Open File History` — история файла.
- `Ctrl + Shift + P` → `GitLens: Compare Working Tree with` — сравнение веток.

## Git Graph

`Ctrl + Shift + P` → `Git Graph: View Git Graph` — визуальная история коммитов, веток и слияний.

## Git History

Правая кнопка на файле → `Git: View File History`.

## Частые команды в терминале

```bash
# Статус
git status

# История в кратком виде
git log --oneline -20

# Разница
git diff
git diff --cached

# Кто менял строки
git blame file.txt

# Ветки
git branch -a
git checkout -b feature-name

# Stash
git stash
git stash pop

# Отмена изменений в файле
git checkout -- file.txt

# Коммит
git add .
git commit -m "message"
```

## Практический пример

```bash
# Найти коммит, в котором появилась строка
git log -S "function_name" --oneline

# Показать изменения файла за последние 5 коммитов
git log -p -5 -- file.txt
```
