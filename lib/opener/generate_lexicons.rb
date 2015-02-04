require 'optparse'
require 'csv'

options  = {}
lexicons = []
file     = nil
OptionParser.new do |opts|
  opts.banner = "Usage: import_lexicons.rb [options]"

  opts.on("-i", "--input FILE", "Input FILE") do |i|
    options[:input] = i
  end

  opts.on("-o", "--output FILE", "Output FILE") do |o|
    options[:output] = o
  end

  opts.on("--append [OPT]", "Appends the generated lexicons to the existing output") do |a|
    options[:append] = a
  end

  opts.on("-h", "--help", "Display this screen") do
    puts opts
    exit
  end
end.parse!

def write_to_file(file, lexicons, option)
  File.open(file, option) do |file|
    lexicons.each do |lexicon|
      file.write "#{lexicon.join('\t')}\n"
    end
  end
end

CSV.foreach(options[:input], {:headers => true}) do |row|
  lexicons << [row["lemma"], row["pos"], row["property"]]
end

if options[:append]
  write_to_file(options[:output], lexicons, 'a')
else
  write_to_file(options[:output], lexicons, 'w')
end
