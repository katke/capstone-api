FactoryGirl.define do
  factory :noise do
    description "Foobar"
    noise_type "transit"
    lat 47.9
    lon -122.901
    decibel 70
    reach 10
    seasonal false
  end
end
