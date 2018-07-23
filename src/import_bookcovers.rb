# Importiert die Bookcover aus ps-Biblio für die Bücherei-Homepage, so dass sie von dort aus
# von der App geladen werden können (oder auch in Blog-Beiträgen verwendet werden können)

require 'optparse'
require 'mini_magick'

STDOUT.sync = true 

# Parse Options
options = {}
input_dir = 'C:\Users\Public\Documents\ps-biblio\global\Datenbanken\psbiblio_hauptdatenbank\Medienfotos'

OptionParser.new do |opts|
  opts.banner = "Usage: import_bookcovers.rb [options]"

  opts.on("-i", "--import_dir", "=NAME", "ps-Biblio Media Cover Directory") do |arg|
    json_filename = arg 
  end
end.parse!

if !input_dir || ! Dir.exist?(input_dir)
  raise "specify ps-Biblio book cover dir with -i"
end

output_dir = File.join(__dir__, "..", "images", "mediacovers")
puts "input=#{input_dir}"
puts "output=#{output_dir}"

if !output_dir || ! Dir.exist?(output_dir)
  raise "output directory not accessible"
end

Dir.foreach(input_dir) do |entry|
  if entry != '.' && entry != '..' && entry =~ /.jpg$/i &&  entry !~ /_t\./        
    input_path = File.join(input_dir, entry)

    ['x160', 'x320'].each do |resolution|
      output_path = File.join(output_dir, resolution, entry)
      if !File.exist?(output_path)
        puts "#{output_path}..."
        cmd = "magick.exe #{input_path} -resize #{resolution} #{output_path}"
        magick_output = `#{cmd}`
        if $CHILD_ERROR
          raise "failed converting image: #{magick_output}"
        end
      end
    end
  end
end

puts "Done."
