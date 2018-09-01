require 'yaml'
require 'json'
#require 'tiny_tds'
require 'odbc_utf8'
#require 'sys/proctable'
#include Sys
require 'dbi'

STDOUT.sync = true 

#ProcTable.ps.each do |process|
#  if process['comm'] == 'sqlservr.exe'
#    puts "SQL Server has PID #{process['pid']}"
#  end
#end

dbcfg = YAML.load_file('database.yml')
puts dbcfg.inspect
puts dbcfg['dataserver']

client = DBI.connect("DBI:ODBC:#{dbcfg['datasource']}",  dbcfg['user'], dbcfg['password'])
#client = ODBC.connect(dbcfg['datasource'],  dbcfg['user'], dbcfg['password'])
#client = TinyTds::Client.new( username: dbcfg['user'], 
#                              password: dbcfg['password'], 
#                              dataserver:  dbcfg['dataserver'],
#                              #host: 'localhost',
#                              #port: 49813,
#                              database: dbcfg['database'], #'PSBIBLIO_HAUPTDATENBANK',
#                           # tds_version: '7.4',#
#                              login_timeout: 5)#

group_conditions = {
  :sl => {
    :name => "Belletristik (Erwachsene und Jugendliche)",
    :sql => "gruppe2='J' or gruppe1=13",
  },
  :kinder => {
    :name => "Kinderbücher",
    :sql => "gruppe1=14 and gruppe2 <> 'J'",
  },
  :sach => {
    :name => "Sachbücher",
    :sql => "gruppe1=12"
  }
}  

group_conditions.each do |key, props|
  json_filename = "top-#{key}.json"
  puts "Generating #{json_filename}..."

  sql = "SELECT TOP 100 COUNT(DISTINCT history.adatum) AS beliebtheit, 
                                        MAX(history.adatum) as zuletzt, medien.mnummer,  titel, gruppe2 
                         FROM HISTORY
                         INNER JOIN medien ON medien.mnummer = history.mnummer
                         WHERE #{props[:sql]}
                         GROUP by medien.MNUMMER, titel, gruppe2
                         ORDER by beliebtheit desc, zuletzt desc"

  rows = client.execute(sql)
  books = []

  rows.each do |row|     
puts row.inspect  
    books << {
      :mediaNum => row['mnummer'].strip,
      #:mediaType => media_type,
      #:isbn => isbn,
      #:author => get_elem_text(tr, '#autor').gsub(/:.*$/, ''),
      :title => row['titel'].strip, #get_elem_text(tr, '#titel'),
      #:subtitle => get_elem_text(tr, '#utitel'),
      #:publisher => get_elem_text(tr, '#verlag'),
      #:coverUrl => cover_url,
      #:available => available      
    }  
  end
  
  json_file = File.open(json_filename, "w")
  json_file.puts JSON.pretty_generate(books)  
  json_file.close
end  