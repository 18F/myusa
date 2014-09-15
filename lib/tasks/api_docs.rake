API_SOURCE_FILES = Rake::FileList[
  "api_docs/api_doc.md",
  "api_docs/tokeninfo.md",
  "api_docs/profile.md",
  "api_docs/task.md",
  "api_docs/notification.md",
  "api_docs/logout.md"
]

namespace :api_docs do
  desc 'generate API documentation'
  task :generate do
    File.open("public/api.md", 'w') do |f|
      puts "merging source markdown files"
      API_SOURCE_FILES.each do |t|
        f.puts IO.read(t)
      end
    end
    puts "generating app/views/marketing/_developer.html.erb"
    system 'aglio', '-t', 'lib/aglio/myusa.jade', '-i', 'public/api.md', '-o', 'app/views/marketing/_developer.html.erb'
  end

  desc 'remove generated HTML and markdown'
  task :clean do
    files = Rake::FileList['public/developer/api.md', 'apps/views/marketing/_developer.html.erb']
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
