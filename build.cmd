@echo off

call .\.env\Scripts\activate.bat

mkdocs build

echo.

pause