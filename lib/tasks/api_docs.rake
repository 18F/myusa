

file "public/developer/api.html" => "public/developer/api.md" do
  system 'aglio', '-i', 'public/developer/api.md', '-o', 'public/developer/api.html'
end

namespace :api_doc do
  desc 'generate API documentation'
  task :generate => "public/developer/api.html"
end
