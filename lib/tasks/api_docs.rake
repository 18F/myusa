

SOURCE_FILES = Rake::FileList[
  "public/developer/api_doc.md",
  "api_docs/tokeninfo.md",
  "api_docs/profile.md",
  "api_docs/task.md",
  "api_docs/notification.md",
  "api_docs/logout.md"
]

file "public/developer/api.md" => SOURCE_FILES do |t|
  puts "merging source markdown files"
  File.open("public/developer/api.md", 'w') do |f|
    f.puts t.sources.map {|md| IO.read(md) }
  end
end

rule ".html" => ".md" do |t|
  puts "generating #{t.name}"
  system 'aglio', '-i', t.source, '-o', t.name
end

namespace :api_docs do
  desc 'generate API documentation'
  task :generate => "public/developer/api.html"


  desc 'remove generated HTML and markdown'
  task :clean do
    files = Rake::FileList['public/developer/api.md', 'public/developer/api.html']
    files.each do |f|
      if File.exists?(f)
        puts "deleting #{f}"
        File.delete(f)
      end
    end
  end

  desc 'clean and regenerate API documentation'
  task :regenerate => [:clean, :generate]
end
