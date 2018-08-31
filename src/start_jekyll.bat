@rem Jekyll-Server starten
@set mypath=%~dp0
@cd %mypath%
@cd ..
git pull
bundle exec jekyll serve --watch
pause
