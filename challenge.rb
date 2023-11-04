require 'json'
require 'fileutils'

# === Company
# Encapsulates the attributes of a company, and also holds an array
# of users belonging to the company.
class Company
  attr_accessor :id, :name, :top_up, :email_status, :users

  def initialize(id:, name:, top_up:, email_status:)
    self.id = id.to_i
    self.name = name
    self.top_up = top_up.to_i
    self.email_status = email_status
    self.users = []
  end

  # Returns a string that summarizes the user top ups for the company.
  def summarize
    return if users.count == 0
    "\n\tCompany Id: #{id}" +
    "\n\tCompany Name: #{name}" +
    "\n\tUsers Emailed:" +
    summarize_users(users.select(&:email_sent)) +
    "\n\tUsers Not Emailed:" +
    summarize_users(users.reject(&:email_sent)) +
    summarize_top_ups +
    "\n"
  end

  private

  def summarize_users(users)
    users.sort_by { |u| u.last_name}.inject("") do |users_summary, user|
      users_summary + user.summarize 
    end
  end

  def summarize_top_ups
    total_top_ups = users.inject(0) { |top_ups, user| top_ups + user.top_up }
    "\n\t\tTotal amount of top ups for #{name}: #{total_top_ups}"
  end
end

# === User
# Encapsulates the attributes of a user.
#
# The user's token balance is stored in 2 attributes: starting_tokens and top_up.
# This allows for a user to have multiple top ups without losing track of the 
# original starting amount. This is not a current requirement, but may be nice to
# have in the future.
class User
  attr_accessor :id, :first_name, :last_name, :email, :company_id, :email_status, :active_status, :starting_tokens, :top_up, :email_sent

  def initialize(id:, first_name:, last_name:, email:, company_id:, email_status:, active_status:, tokens:)
    self.id = id.to_i
    self.first_name = first_name
    self.last_name = last_name
    self.email = email
    self.company_id = company_id.to_i
    self.email_status = email_status
    self.active_status = active_status
    self.starting_tokens = tokens.to_i
    self.top_up = 0
    self.email_sent = false
  end

  # Returns the current token balance.
  def current_token_balance
    starting_tokens + top_up
  end

  # Returns a string the summarizes the tokens for the user.
  def summarize
    "\n\t\t#{last_name}, #{first_name}, #{email}" +
    "\n\t\t  Previous Token Balance, #{starting_tokens}" +
    "\n\t\t  New Token Balance #{current_token_balance}"
  end
end

# Loads the specified file as JSON and returns the resulting hash.
# An error opening the file or parsing the data will output an error
# and halt execution.
def load_json_data(file_name)
  data = JSON.load_file(file_name, symbolize_names: true)
rescue => e
  puts "Error loading #{file_name}: #{e}"
  exit 1
end

# Loads the specified JSON file and returns the results as an array
# of User instances. An error mapping user JSON to a User instance will
# output an error and halt execution.
def load_users(file_name)
  users = load_json_data(file_name)
  users.map! do |user|
    User.new(**user)
  rescue => e
    puts "ERROR: Unable to load user #{user} - #{e}"
    exit 1
  end
  users
end

# Loads the specified JSON file and returns the results as a hashmap of 
# Company instances keyed by company_id. An error mapping company JSON to
# a Company instance will output an error and halt execution.
def load_companies(file_name)
  companies = load_json_data(file_name)
  companies_by_id = {}
  companies.each do |c|
    company = Company.new(**c)
    if companies_by_id[company.id]
      puts "Duplicate company id found: '#{company.name}' and '#{companies_by_id[company.id].name}' both have id #{company.id}."
      exit 1
    end
    companies_by_id[company.id] = company 
  rescue => e
    puts "ERROR: Unable to load company #{c} - #{e}"
    exit 1
  end  
  companies_by_id
end

# Calculates the top up for users and adds the user to its associated
# company. User that are inactive or do not belong to a company will be 
# skipped.
def top_up_users(users, companies)
  users.each do |user|
    print "."
    $stdout.flush
    company = companies[user.company_id]
    next if user.active_status == false || company == nil
    user.top_up += company.top_up
    user.email_sent = company.email_status && user.email_status
    company.users << user
  end
end

# Writes a summary of the user top ups, grouped by company, to the
# specified output file.
def output_companies_summary(output_file, companies)
  File.open(output_file, "w") do |f|
    companies.keys.sort.each { |id| f.write companies[id].summarize }
    f.write("\n")
  end
end

# === Main script starts here 

USERS_FILE = "users.json"
COMPANIES_FILE = "companies.json"
OUTPUT_FILE = "output.txt"

users = load_users(USERS_FILE)
puts "Users: #{users.count}"

companies = load_companies(COMPANIES_FILE)
puts "Companies: #{companies.count}"

top_up_users(users, companies)

output_companies_summary(OUTPUT_FILE, companies)

puts "\nDone processing. Results in #{OUTPUT_FILE}"

puts FileUtils.compare_file(OUTPUT_FILE, "example_output.txt") ? "Output passed verification" : "Output failed verification"
