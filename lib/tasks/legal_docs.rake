LEGAL_SOURCE_FILES = Rake::FileList[
  "public/legal/overview.md",
  "public/legal/terms.md",
  "public/legal/privacy.md",
  "public/legal/linking.md",
  "public/legal/pra.md"
]

namespace :legal_docs do
  desc 'generate legal documentation'
  task :generate do
    File.open("public/legal.md", 'w') do |f|
      puts "merging source markdown files"
      LEGAL_SOURCE_FILES.each do |t|
        f.puts IO.read(t)
      end
    end
    puts "generating app/views/marketing/_legal.html.erb"
    system 'aglio', '-t', 'lib/aglio/myusa.jade', '-i', 'public/legal.md', '-o', 'app/views/marketing/_legal.html.erb'
  end

  desc 'remove generated HTML and markdown'
  task :clean do
    files = Rake::FileList['public/legal.md', 'app/views/marketing/_legal.html.erb']
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
