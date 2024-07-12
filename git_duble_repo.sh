#!/bin/bash

# Проверка наличия аргумента для комментария коммита
if [ -z "$1" ]; then
    echo "Ошибка: Необходимо ввести комментарий для коммита."
    echo "Использование: $0 \"Комментарий для коммита\""
    exit 1
fi

commit_message=$1

# Добавление всех изменений в индекс
git add .

# Создание коммита с указанным комментарием
git commit -m "$commit_message"
# List repo
repos=("git@github.com:tms-dos21-onl/Alex_Horskiy.git" "git@github.com:Horskiy/Alex_Horskiy.git")

# The branch to be strangled
branch="main"

for repo in "${repos[@]}"; do
    echo "Pushing to $repo..."
    git push "$repo" "$branch"
done

