@rem Neue Coverbilder in Homepage importieren und hochladen
set mypath=%~dp0
@echo %mypath%
cd /D %mypath%
git pull
cd src
call bundle exec ruby import_bookcovers.rb
cd ..
git add .
git commit -m "Neue Coverbilder"
git push
pause