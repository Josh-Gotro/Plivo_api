require 'rubygems'
require 'plivo'

include Plivo

# puts Rails.application.credentials.plivo[:auth_id]
# puts Rails.application.credentials.plivo[:auth_token]

# client = RestClient.new("xxxxxxxxxxxxxxxxxxx", "xxxxxxxxxxxxxxxxxxxxx")
# client = RestClient.new(`#{auth}`, `#{tok}`)

message_created = client.messages.create(
  '+15125185935',
  %w[+15127448789],
  'Test using tight '
)

# Rails.application.credentials.plivo[:auth_id]
# Rails.application.credentials.plivo[:auth_token]