@rem Top100 aktualsieren und auf Homepage hochladen
@set mypath=%~dp0
@echo %mypath%
@cd /D %mypath%
@echo Statistik generieren...
git pull
call bundle exec ruby db_stat.rb
