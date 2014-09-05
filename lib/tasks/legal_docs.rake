SOURCE_FILES = Rake::FileList[
  "public/legal/overview.md",
  "public/legal/terms.md",
  "public/legal/privacy.md",
  "public/legal/linking.md",
  "public/legal/pra.md"
]

file "public/legal.md" => SOURCE_FILES do |t|
  puts "merging source markdown files"
  File.open("public/legal.md", 'w') do |f|
    f.puts t.sources.map {|md| IO.read(md) }
  end
end

rule ".html" => ".md" do |t|
  puts "generating #{t.name}"
  system 'aglio', '-i', t.source, '-o', t.name
end

namespace :legal_docs do
  desc 'generate legal documentation'
  task :generate => "public/legal.html"


  desc 'remove generated HTML and markdown'
  task :clean do
    files = Rake::FileList['public/legal.md', 'public/legal.html']
    files.each do |f|
      if File.exists?(f)
        puts "deleting #{f}"
        File.delete(f)
      end
    end
  end

  desc 'clean and regenerate legal documentation'
  task :regenerate => [:clean, :generate]
end
