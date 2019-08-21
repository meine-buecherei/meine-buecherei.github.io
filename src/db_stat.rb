# Erzeuge Büchereistatistiken aus Datenbank

require 'yaml'
require 'odbc_utf8'
require 'dbi'
require 'fileutils'
require 'axlsx'

#
# MAIN
#
STDOUT.sync = true 

dbcfg = YAML.load_file('database.yml')

client = DBI.connect("DBI:ODBC:#{dbcfg['datasource']}",  dbcfg['user'], dbcfg['password'])

group_conditions = {
  :sach => {
    :name => "Sachbücher",
    :sql => "medien.gruppe1=12"
  },
  :sl => {
    :name => "Belletristik",
    :sql => "medien.gruppe1=13",
  },
  :j => {
    :name => "Jugend",
    :sql => "medien.gruppe2='J'",
  },
  :kinder => {
    :name => "Kinderbücher",
    :sql => "medien.gruppe1=14 and medien.gruppe2 <> 'J'",
  },
  :cd => {
    :name => "CDs",
    :sql => "medien.mcode=5"
  },
  :dvd => {
    :name => "DVDs",
    :sql => "medien.mcode=17"
  },
  :summe => {
    :name => "Medien insgesamt",
    :sql => "1=1"
  }
}  

sql = "SELECT ausleih_datum Datum,"

puts "Datenbankabfrage..."
group_conditions.each do |key, props|
  
  # Teilabfragen zusammensetzen
  sql += "((select count(*) from medien, ausleih 
            where cast(ausleih.adatum as date) = tage.ausleih_datum and ausleih.MNUM = medien.MNUMMER
                  and #{props[:sql]}
            ) 
          + (select count(*) from medien, history 
            where cast(history.adatum as date) = tage.ausleih_datum and history.mnummer = medien.MNUMMER
                  and #{props[:sql]}
            )) [#{props[:name]}]"

  if key != group_conditions.keys.last
    sql += ", "
  end  
end  

sql += " from
  (
    select distinct cast(adatum as date) ausleih_datum from AUSLEIH
    union
    select distinct cast(adatum as date) ausleih_datum from history
  ) tage
  order by tage.ausleih_datum desc"

rows = client.execute(sql)

tmpdir = "#{ENV['TEMP']}\\bücherei"
if !Dir.exists?(tmpdir)
  FileUtils.mkpath(tmpdir)
end
  
xlsx_file = tmpdir + "\\Büchereistatistik-" + Time.now.strftime("%Y-%m-%d-%H-%M-%S") + ".xlsx"
puts "Generiere Datei #{xlsx_file}..."
excel = Axlsx::Package.new
workbook = excel.workbook
worksheet = workbook.add_worksheet(:name => "Tagesstatistik")

headers = ['Datum']
date_format = workbook.styles.add_style(:format_code => 'NNNND. MMMM YYYY')
headers.concat(group_conditions.values.collect {|cond| cond[:name]})
worksheet.add_row(headers)

rows.each_with_index do |row, row_num|     
  row_content = row.to_a
  row_content[0] = Date.parse(row_content[0])
 
  worksheet.add_row(row_content, :style => [date_format])
end  

client.disconnect

# Kopfzeile einfrieren
worksheet.sheet_view.pane do |pane|
  pane.top_left_cell = "A2"
  pane.state = :frozen_split
  pane.y_split = 1
  pane.x_split = 0
  pane.active_pane = :bottom_right
end

worksheet.column_widths( 28, *([12] * headers.count))

excel.serialize(xlsx_file)

puts "Öffne Datei..."
system("cmd /c \"start #{xlsx_file}\"")
puts "Fertig."
