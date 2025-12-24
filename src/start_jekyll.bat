@rem Jekyll-Server starten
@set mypath=%~dp0
@cd %mypath%
@cd ..
git pull
call bundle install
call bundle exec jekyll serve --watch --trace
pause
