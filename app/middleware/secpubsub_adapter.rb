require 'faye/websocket'

module Secpubsub
  class Adapter
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "chat-demo"

    def initialize(app, options)
      @app     = app
      @channels = {}
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
        ws.on :open do |event|
          p [:open, ws.object_id]
        end

        ws.on :message do |event|
          data = unpack(event.data)
          
          if authenticated(data)

            case data[:command]
            when 'subscribe'
              subscribe(data, ws)
            when 'publish'
              publish(data)
              ws.close(1000, 'publish request fulfilled')
            else
              ws.close(1000, 'unknown command')
            end
          else 
            ws.close(1000, 'authentication failed') #neither 1008 code works, or reason???
          end
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code, event.reason]
          @channels.each do |k,v|
            v.delete(ws)
          end
          ws = nil
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    def unpack(data)
      JSON.parse(data).symbolize_keys
    end

    def authenticated(data)
      Secpubsub.subscription(data)[:auth_token] == data[:auth_token]
    end
  
    def subscribe(data, ws)
        ch = data[:channel]
        @channels[ch] ||= []
        @channels[ch] << ws
        p [:subscribe, ch, "subscribers: #{(@channels[ch]||[]).count}"]    
    end

    def publish(data)
      ch = data[:channel]
      sanitised_data = data.reject {|k,v| k == :auth_token}.to_json
      p [:publish, sanitised_data]
      channel_clients = @channels[ch] || []
      channel_clients.each do |client| 
        client.send(sanitised_data) 
        p [:sent, ch, client.object_id, sanitised_data]
      end
    end   
  end
end