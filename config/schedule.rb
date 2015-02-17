set :output, "/../lib/cron/cron_log.log"

# every 1.day, :at => '3:30 am' do
#   rake 'update_data'
# end

every 30.minutes do
  rake 'update_data'
end
