@rem Neue Coverbilder in Homepage importieren und hochladen
@set mypath=%~dp0
@echo %mypath%
@cd /D %mypath%
@echo Coverbilder konvertieren...
git pull
call bundle exec ruby import_bookcovers.rb
call bundle exec ruby db_extract.rb

cd ..
@echo Aenderungen der Homepage hochladen...
git add .
git commit -m "Aktualisiert durch coversync.bat"
git push
pause