# Erzeuge Büchereistatistiken aus Datenbank

require 'yaml'
require 'odbc_utf8'
require 'dbi'
require 'fileutils'
require 'axlsx'

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

def add_header(worksheet, headers)
  header_format = worksheet.workbook.styles.add_style(:b => false, :bg_color => "ccffe6")
  worksheet.add_row(headers, :style => [header_format] * headers.count)

  # Kopfzeile einfrieren
  worksheet.sheet_view.pane do |pane|
    pane.top_left_cell = "A2"
    pane.state = :frozen_split
    pane.y_split = 1
    pane.x_split = 0
    pane.active_pane = :bottom_right
  end
end

def leihstatistik(workbook, db_client, group_conditions)
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

  rows = db_client.execute(sql)
    
  worksheet = workbook.add_worksheet(:name => "Tagesstatistik")

  headers = ['Datum']
  date_format = workbook.styles.add_style(:format_code => 'NNNND. MMMM YYYY')
  headers.concat(group_conditions.values.collect {|cond| cond[:name]})
  add_header(worksheet, headers)

  months = {}
  years = {}
  rows.each_with_index do |row, row_num|     
    row_content = row.to_a
    date = Date.parse(row_content[0])
    row_content[0] = date
   
    worksheet.add_row(row_content, :style => [date_format])
    
    # Monatsstatistiken vorbereiten
    month = date.strftime("%Y-%m")
    if !months[month]
      months[month] = [0] * 7
    end
    if !years[date.year]
      years[date.year] = [0] * 7
    end

    (1..(row_content.size - 1)).each do |i|
      months[month][i-1] += row_content[i]
      years[date.year][i-1] += row_content[i]
    end  
  end  

  worksheet.column_widths( 28, *([15] * headers.count))

  # Langzeitstatistik
  worksheet = workbook.add_worksheet(:name => "Langzeitstatistik")
  month_format = workbook.styles.add_style(:format_code => 'MMMM YYYY')
  headers = ['Monat']
  headers.concat(group_conditions.values.collect {|cond| cond[:name]})
  
  add_header(worksheet, headers)
  
  year_format = workbook.styles.add_style( {:alignment => {:horizontal => :right}, :b => true}  )

  months.keys.sort.each do |month|
    date = Date.parse(month + "-01")
    row_content = [date]
    row_content.concat(months[month])
    
    worksheet.add_row(row_content, :style => [month_format])  
    
    if date.month == 12 || month == months.keys.sort.last
      row_content = ["#{date.year} (Summe)"]
      row_content.concat(years[date.year])
      worksheet.add_row(row_content, :style => [year_format] * 8)  
      worksheet.add_row([])
    end
    
  end

  worksheet.column_widths( 28, *([15] * headers.count))  
end

#
# MAIN
#
STDOUT.sync = true 

dbcfg = YAML.load_file('database.yml')

db_client = DBI.connect("DBI:ODBC:#{dbcfg['datasource']}",  dbcfg['user'], dbcfg['password'])



tmpdir = "#{ENV['TEMP']}\\bücherei"
if !Dir.exists?(tmpdir)
  FileUtils.mkpath(tmpdir)
end
  
xlsx_file = tmpdir + "\\Büchereistatistik-" + Time.now.strftime("%Y-%m-%d-%H-%M-%S") + ".xlsx"
puts "Generiere Datei #{xlsx_file}..."
excel = Axlsx::Package.new
workbook = excel.workbook
leihstatistik(workbook, db_client, group_conditions)

db_client.disconnect

excel.serialize(xlsx_file)

puts "Öffne Datei..."
system("cmd /c \"start #{xlsx_file}\"")
puts "Fertig."
