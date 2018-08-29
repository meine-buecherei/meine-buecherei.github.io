@rem Neue Coverbilder in Homepage importieren und hochladen
@set mypath=%~dp0
@echo %mypath%
@cd /D %mypath%
@echo "Coverbilder konvertieren..."
git pull
call bundle exec ruby import_bookcovers.rb
cd ..
@echo "Änderungen der Homepage hochladen..."
git add .
git commit -m "Neue Coverbilder"
git push
pause