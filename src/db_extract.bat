@rem Top100 aktualsieren und auf Homepage hochladen
@set mypath=%~dp0
@echo %mypath%
@cd /D %mypath%
@echo Top 100 aktualisieren...
git pull
call bundle exec ruby db_extract.rb

cd ..
@echo Aenderungen der Homepage hochladen...
git add .
git commit -m "Aktualisiert durch db_extract.bat"
git push
pause