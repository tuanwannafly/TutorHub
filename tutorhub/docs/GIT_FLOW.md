# Git Flow Cheatsheet (TutorHub)

This project uses **Git Flow**.

```
master                → production, tagged releases only
  └── develop          → integration branch (default for daily work)
        ├── feature/*  → all new work
        ├── release/*  → freeze + final fixes before tagging
        └── hotfix/*   → emergency patches off master
```

## Initial setup (one time, fresh repo)

```bash
cd tutorhub
git init
git add . && git commit -m "chore: initial rails app scaffold + docs"

git checkout -b develop
git push -u origin develop
git push -u origin master
```

## Working on a feature

```bash
git checkout develop && git pull
git checkout -b feature/<sprint-id>-<short-name>

# … do work, commit using Conventional Commits:
#   feat: add booking service with conflict handling
#   test: add concurrency spec
#   chore: update rubocop config
#   docs: update README

git push -u origin feature/<name>

# Open a PR on GitHub, self-review, squash-merge.
git checkout develop && git pull
git branch -d feature/<name>
```

## Tagging the end of a sprint

```bash
git tag -a v0.<n> -m "Sprint N complete: <one-liner>"
git push origin v0.<n>
```

## Cutting a release

```bash
git checkout develop && git pull
git checkout -b release/v1.0
# … light fixes only, bump version in config/version.rb if present
git checkout master && git merge --no-ff release/v1.0
git tag -a v1.0 -m "First stable release"
git checkout develop && git merge --no-ff release/v1.0
git branch -d release/v1.0
```

## Hotfix

```bash
git checkout master
git checkout -b hotfix/<short-name>
# … patch …
git commit -m "fix: <description>"
git checkout master && git merge --no-ff hotfix/<short-name>
git tag -a v1.0.1
git checkout develop && git merge --no-ff hotfix/<short-name>
```
