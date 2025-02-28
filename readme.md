
Для создания документации используется генератор статических сайтов [MkDocs](https://www.mkdocs.org/) с темой оформления [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/getting-started/).

## Краткая инструкция

1. Установить [Python 3.x](https://www.python.org/downloads/)
2. Запустить скрипт `install.cmd` для создания virtual environment и установки необходимых пакетов
3. Запустить скрипт `serve.cmd` для запуска локального сервера mkdocs
4. Для превью документации открыть в браузере адрес [http://localhost:8000/](http://localhost:8000)

По мере необходимости, запускать скрипт `install.cmd` для обновления пакетов.

Скрипт `build.cmd` предназначен для создания оффлайн версии документации (будет создана во вложенной папке site).