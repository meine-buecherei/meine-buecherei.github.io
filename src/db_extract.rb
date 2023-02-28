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

def generate_html(books, html_filename, key, category_name)
  html_file = File.open(html_filename, "w")
  
  now = Time.now.strftime("%d.%m.%Y, %H:%M Uhr")
  
  html_file.puts <<HTML
---
layout: page
title: "Top 100 - #{category_name}"
permalink: /top100-#{key}/
---
Dies ist die Liste unserer 100 beliebtesten Medien im Bereich __#{category_name}__. 

Ermittelt aus der Westerheimer Bücherei-Datenbank, Stand: _#{now}_. Die Reihenfolge ergibt sich der aus der Gesamtzahl der Ausleihvorgänge innerhalb der letzten 365 Tage sowie dem letzten Ausleihdatum.

<table>
HTML
  
  rank = 0
  books.each do |book|
    rank += 1
    
    image_path = "/images/mediacovers/x160/#{book[:mediaNum]}.jpg"
    if File.exist?("../#{image_path}")
      image_src = image_path
    else
      image_src =  "/images/mediacovers/x160/keinbild.jpg"
    end    

    author = book[:author] || ""
    biblino_details_url = "https://www.biblino.de/index.php?action=5&mnummer=#{book[:mediaNum]}"
    title_link = "<a href=\"#{biblino_details_url}\">#{book[:title]}</a>"
    
    html_file.puts "<tr>" +
                     "<td width=\"70%\"><strong>Platz #{rank}</strong><br><br>" +
                         "<em>#{author}</em><br><br>#{title_link}</td>" +
                     "<td><center><a href=\"#{biblino_details_url}\">" + 
                      "<img src=\"#{image_src}\" style=\"width: auto; height: auto;\"></a></center></td>" +
                   "</tr>"
                   
  end
  
  html_file.puts "</table>"
  html_file.close
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
  json_filename_app17 = "top-#{key}-app17.json"
  json_filename_app16 = "top-#{key}.json"
  html_filename = "../top-#{key}.md"
  
  puts "Generiere top-#{key}..."

  # Abfrage aus der Ausleih-Historie
  sql = "SELECT COUNT(DISTINCT history.adatum) AS beliebtheit, 
                                        MAX(history.adatum) as geliehen_am, 
                                        medien.mnummer, mcode, autor, titel, gruppe2, isbn
                         FROM HISTORY
                         INNER JOIN medien ON medien.mnummer = history.mnummer
                         WHERE (#{props[:sql]})
                           AND (NOWEBOPAC is null or NOWEBOPAC=0)
                           AND history.adatum > DATEADD(year, -1, GETDATE())
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
      b_date = Date.strptime(b[:borrowedAt], "%d.%m.%Y")
      a_date = Date.strptime(a[:borrowedAt], "%d.%m.%Y")

      if b_date != a_date
        b_date <=> a_date
      else
        # bei gleichem Ausleihdatum die zuletzt angeschafften Bücher zuerst zeigen
        b[:mediaNum].to_i <=> a[:mediaNum].to_i
      end
    else
      b[:numBorrowed] <=> a[:numBorrowed]
    end  
  }
  books = books[0..99] # Höchstens 100 Medien in der Liste
  
  # JSON-Datei generieren - für die App...
  # Format bis App Version 16
  puts "Generiere #{json_filename_app16}..."
  json_file = File.open(json_filename_app16, "w")
  json_file.puts JSON.generate(books)  
  #json_file.puts JSON.pretty_generate(books)  
  json_file.close
  
  # Format ab App Version 17 (mit Sync-Zeitpunkt)
  puts "Generiere #{json_filename_app17}..."
  now = Time.now.strftime("%d.%m.%Y, %H:%M Uhr")
  json_file = File.open(json_filename_app17, "w")  
  json_file.puts JSON.generate( { :last_sync => now,
                                  :books => books
                                } )  
  #json_file.puts JSON.pretty_generate(books)  
  json_file.close
    
  # HTML-Datei generieren - für Jekyll/Homepage...
  puts "Generiere #{html_filename}..."
  generate_html(books, html_filename, key, props[:name])
  
  puts "#{books.size} Medien in top-#{key}"
  
end  


client.disconnect
