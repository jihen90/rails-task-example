# lib/tasks/titans.rake
require 'json'

namespace :titans do
  desc "Find the day with the fewest titans sighted"
  task :best_day, [:file_path] => :environment do |_, args|
    file_path = args[:file_path]

    unless file_path
      puts "Please provide the JSON file path"
      next
    end

    begin
      result = find_first_lowest_density_day(file_path)
      puts <<~MESSAGE
      Hello explorers, based on our records,
      the estimated day with the fewest titan sightings is expected to be on day #{result}.
      Remember that the months of January and December are not recommended due to their high risk.
      MESSAGE

    rescue StandardError => e
      puts "Error processing the JSON file: #{e.message}"
    end
    # For any purpose:
    result
  end

  def find_first_lowest_density_day(file_path)
    data = JSON.parse(File.read(file_path))
    find_day_with_least_sightings(data)
  end

  def find_day_with_least_sightings(data)
    min_distance = nil
    day_with_least_sightings = nil
    
    # Exclude January and December for each year.
    # Consider 0 as the first day, and note that both January and December have 31 days.
    # Do not consider leap years for this purpose.
    valid_days_last_year = (31..333).to_a
    valid_days_current_year = (395..698).to_a
  
    data.each do |subarray|
      distance = subarray[1] - subarray[0]
      day_start = subarray[0]
  
      # Validate that it is within the range of accepted months for each year
      next unless valid_days_last_year.include?(day_start) || valid_days_current_year.include?(day_start)
  
      if min_distance.nil? || distance < min_distance || (distance == min_distance && day_start < day_with_least_sightings)
        min_distance = distance
        day_with_least_sightings = day_start
      end
    end
    # Add 1 to get the day the titan was sighted
    day_with_least_sightings + 1
  end
end