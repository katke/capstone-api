set :output, "../lib/cron/cron_log.log"

# every 1.day, :at => '3:30 am' do
#   rake 'update_data'
# end

every 30.minutes do
  rake 'update_data', :environment => 'development'
  puts "Updated dev DB demolition, construction, 911 noise complaints at " + Time.now.to_s
end

every 30.minutes do
  rake 'update_data', :environment => 'production'
  puts "Updated production DB demolition, construction, 911 noise complaints at " + Time.now.to_s
end
