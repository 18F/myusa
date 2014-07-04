#Combine the api documentation markdown and all the api blueprint mark down files into one markdown file
#then render with Aglio

text = File.open('public/developer/api_doc.md', 'r').read
Dir.foreach('api_docs')do |file_name|
  next if file_name == '.' or file_name == '..' or file_name == '.DS_Store'
  file_name = 'api_docs/' + file_name
  text += File.open(file_name, 'r').read
end
File.open('public/developer/api.md', 'w') {|file| file.write(text)}
`aglio -i public/developer/api.md -o public/developer/api.html`
