#!/bin/bash

# List repo
repos=("git@github.com:tms-dos21-onl/Alex_Horskiy.git" "git@github.com:Horskiy/Alex_Horskiy.git")

# The branch to be strangled
branch="main"

for repo in "${repos[@]}"; do
    echo "Pushing to $repo..."
    git push "$repo" "$branch"
done

