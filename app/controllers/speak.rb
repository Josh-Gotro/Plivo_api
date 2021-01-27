require 'rubygems'
require 'sinatra'
require 'plivo'
include Plivo

# Set te caller ID using Dial XML

get '/receive_call' do
    response = Response.new

    speak_body = 'Hello, you just received your first call'
    response.addSpeak(speak_body)
    xml = PlivoXML.new(response)   

    puts xml.to_xml() # Prints the XML
    content_type "application/xml"
    return xml.to_s() # Returns the XML
end