@echo off

set venv=.env

set pk=mkdocs mkdocs-material mkdocs-static-i18n mkdocs-git-revision-date-localized-plugin mkdocs-minify-plugin

if not exist %venv%\ (
  python -m venv %venv%
  
  call .\%venv%\Scripts\activate.bat
  
  pip install %pk%
  
) else (
  call .\%venv%\Scripts\activate.bat
  
  pip install --upgrade --force-reinstall %pk%
  echo.
  
  pip show %pk%
)

echo.

pause