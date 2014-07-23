require 'rubygems'

  desc "generate api documentation html file"
  task :make_api_html => :environment do

    #Generate the API blueprint markdown files
    #Combine the api documentation markdown and all the api blueprint markdown files into one markdown file
    #then render with Aglio
    puts ""
    puts "Running API rspec tests......."
    %x{bundle exec rspec spec/requests/notification_spec.rb}
    %x{bundle exec rspec spec/requests/profile_spec.rb}
    %x{bundle exec rspec spec/requests/task_spec.rb}
    puts "Loading markdown files .........."
    text = File.open('public/developer/api_doc.md', 'r').read
    text += File.open('api_docs/profile.md', 'r').read
    text += File.open('api_docs/task.md', 'r').read
    text += File.open('api_docs/notification.md', 'r').read
    File.open('public/developer/api.md', 'w') {|file| file.write(text)}
    puts "Rendering with Aglio ................"
    %x{aglio -i public/developer/api.md -o public/developer/api.html}

end