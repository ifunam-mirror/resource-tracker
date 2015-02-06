# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'factory_girl'

unless Rails.env.production?
  100.times do
    p = FactoryGirl.build(:project)
    Random.rand(1..20).times do
      p.expenses << FactoryGirl.build(:expense)
    end
    p.save
  end
end
