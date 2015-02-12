task :update_data => :environment do
  Noise.refresh_data
end
