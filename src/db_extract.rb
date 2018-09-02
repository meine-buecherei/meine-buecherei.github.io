# TOP 100-Listen aus der Datenbank extrahieren und als JSON-Dateien für den Zugriff durch die App generieren

require 'yaml'
require 'json'
require 'odbc_utf8'
require 'dbi'

# Datensatz in Hash umwandeln (Attributnamen wie in der App)
def row2book(row)
    media_type = case row['mcode'] 
    when 1
      'book'
    when 5
      'CD'
    when 17
      'DVD'      
    end
    
    borrowed_at = ""
    if row['geliehen_am'] =~ /^(\d+)-(\d+)-(\d+)/ # "2018-08-07T19:52:37+00:00"
      borrowed_at = "#{$3}.#{$2}.#{$1}"
    end  
    book = {
      :mediaNum => row['mnummer'].strip,
      :mediaType => media_type,
      :isbn => row['isbn'] ? row['isbn'].strip : "",
      :author => row['autor'] ? row['autor'].strip : "",
      :title => row['titel'] ? row['titel'].strip : "",
      :numBorrowed => row['beliebtheit'],
      :borrowedAt => borrowed_at
    }  
    
    return book
end

#
# MAIN
#
STDOUT.sync = true 

dbcfg = YAML.load_file('database.yml')

client = DBI.connect("DBI:ODBC:#{dbcfg['datasource']}",  dbcfg['user'], dbcfg['password'])

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
  },
  :cd => {
    :name => "CDs",
    :sql => "mcode=5"
  },
  :dvd => {
    :name => "DVDs",
    :sql => "mcode=17"
  }
}  

group_conditions.each do |key, props|
  json_filename = "top-#{key}.json"
  puts "Generiere #{json_filename}..."

  # Abfrage aus der Ausleih-Historie
  sql = "SELECT TOP 100 COUNT(DISTINCT history.adatum) AS beliebtheit, 
                                        MAX(history.adatum) as geliehen_am, 
                                        medien.mnummer, mcode, autor, titel, gruppe2, isbn
                         FROM HISTORY
                         INNER JOIN medien ON medien.mnummer = history.mnummer
                         WHERE #{props[:sql]}
                         GROUP by medien.MNUMMER, titel, autor, gruppe2, mcode, isbn
                         ORDER by beliebtheit desc, geliehen_am desc"

  rows = client.execute(sql)
  books = []

  rows.each do |row|     
    books <<  row2book(row)
  end  
  rows.finish
  
  # Abfrage aus den gerade ausgeliehenen Medien
  sql = "SELECT medien.mnummer, mcode, autor, titel, gruppe2, isbn, adatum as geliehen_am
                         FROM AUSLEIH
                         INNER JOIN medien ON medien.mnummer = ausleih.mnum
                         WHERE #{props[:sql]}"
  rows = client.execute(sql)
  
  rows.each do |row|
    new_book = row2book(row) 
    book_in_list = books.find { |book| book[:mediaNum] == new_book[:mediaNum] }
    if !book_in_list.nil?
      book_in_list[:numBorrowed] += 1
      book_in_list[:borrowedAt] = new_book[:borrowedAt]
    else
      new_book[:numBorrowed] = 1
      books << new_book
    end
  end
  rows.finish
  
  # Sortieren nach Anzahl Ausleihen, dann nach letzter Ausleihe
  books.sort! { |a, b| 
    if b[:numBorrowed] == a[:numBorrowed]
      Date.strptime(b[:borrowedAt], "%d.%m.%Y") <=> Date.strptime(a[:borrowedAt], "%d.%m.%Y")
    else
      b[:numBorrowed] <=> a[:numBorrowed]
    end  
  }
  books = books[0..99] # Höchstens 100 Medien in der Liste
  
  json_file = File.open(json_filename, "w")
  json_file.puts JSON.generate(books)  
  #json_file.puts JSON.pretty_generate(books)  
  json_file.close
  
  puts "#{books.size} Medien in #{json_filename}"
  
end  


client.disconnect
