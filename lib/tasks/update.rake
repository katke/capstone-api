# namespace :say_hi do
task :refresh_data do

end


task :greet => :environment do # Need to load environment!
  puts "I just wrote a custom rake task!"
end

task :ask => :greet do #runs greet first
  puts "Blargh!"
end

task :all => [:greet, :ask] # to consolidate both tasks in one method if you want to run both

# end

# command line prompt using namespace will be "rake say_hi:ask"
