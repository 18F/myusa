API_SOURCE_FILES = Rake::FileList[
  "api_docs/api_doc.apib",
  "api_docs/getting_started.apib",
  "api_docs/branding.apib",
  "api_docs/oauth.apib",
  "api_docs/profile.apib",
  "api_docs/task.apib",
  "api_docs/notification.apib",
  "api_docs/logout.apib"
]

DEVELOPER_MERGED_PATH = Rails.root.join('public', 'api.apib').to_s
DEVELOPER_ERB_PATH = Rails.root.join('app', 'views', 'marketing', '_developer.html.erb').to_s
AGLIO_THEME_PATH = Rails.root.join('lib', 'aglio', 'myusa.jade').to_s

namespace :api_docs do
  desc 'generate API documentation'
  task :generate do
    File.open(DEVELOPER_MERGED_PATH, 'w') do |f|
      puts "merging source markdown files"
      API_SOURCE_FILES.each do |t|
        f.puts IO.read(t) + "\n"
      end
    end
    puts "generating #{DEVELOPER_ERB_PATH}"
    puts "aglio -t #{AGLIO_THEME_PATH} -i #{DEVELOPER_MERGED_PATH} -o #{DEVELOPER_ERB_PATH}"
    system 'aglio', '-t', AGLIO_THEME_PATH, '-i', DEVELOPER_MERGED_PATH, '-o', DEVELOPER_ERB_PATH
  end

  desc 'remove generated HTML and markdown'
  task :clean do
    files = Rake::FileList[DEVELOPER_MERGED_PATH, DEVELOPER_ERB_PATH]
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
