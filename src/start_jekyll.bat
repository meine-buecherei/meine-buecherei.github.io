@rem Jekyll-Server starten
@set mypath=%~dp0
@cd %mypath%
@cd ..
bundle exec jekyll serve --watch
pause
