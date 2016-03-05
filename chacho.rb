require 'bundler'
Bundler.require

require 'json'

class Chacho < Sinatra::Base

  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    ENV['CREDENTIALS'].split(",").map {|cred| Rack::Utils.secure_compare(cred, "#{username}:#{password}")}.include?(true)
  end

  post '/' do
    data = JSON.parse(request.body.read)
    puts data.inspect
    # requestId, timestamp, type, ...
    case data['request']['type']
    when 'LaunchRequest'
    when 'IntentRequest'
      # intent => { name, slots => { string => { name => string, value => string } } }
    when 'SessionEndedRequest'
      # reason
    end

    status(200)
    body({
      version: '1.0',
      # session: {} # key/value pairs to set
      response: {
        card: {
          content:  'Hello World',
          title:    'Hello World',
          type:     'Simple'
        },
        outputSpeech: {
          text: 'Hello World',
          type: 'PlainText'
        },
        reprompt: {
          outputSpeech: {
            text: 'Can I help you with anything else?',
            type: 'PlainText'
          }
        },
        shouldEndSession: true
      }
    }).to_json
  end

end
