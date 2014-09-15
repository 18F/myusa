
namespace :assets do

  desc 'Create soft links as non digested assets for the 500.html file'
  task soft_links: :environment do
    Rake::Task['assets:precompile'].invoke
    assets = Dir.glob(File.join(Rails.root, 'public/assets/**/*'))
    manifest_path = assets.find do
      |f| f =~ /(manifest)(-{1}[a-z0-9]{32}\.{1}){1}/
    end
    if manifest_path.blank?
      puts 'Could not find any assets'
    else
      manifest_data = JSON.load(File.new(manifest_path))
      manifest_data['assets'].each do |asset_name, file_name|
        next unless asset_name == '500.html'
        file_path = File.join(Rails.root, 'public/assets', file_name)
        asset_path = File.join(Rails.root, 'public/assets', asset_name)
        FileUtils.ln_s(file_path, asset_path, force: true)
      end
    end
  end
end
