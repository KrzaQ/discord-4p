require 'json'
require 'httpclient'

class FourProgrammers

    URL = 'https://api.4programmers.net/v1'

    def initialize
        @c = HTTPClient.new
    end

    def get_topics_since id = nil
        data = []
        (1..).each do
            current = get_single_page(_1)[:data]
            unless id
                return current
            else
                data += current.reject{ |e| e[:id] <= id }
                return data if current.last[:id] <= id
            end
        end
    end

    def get_single_page page = 1
        url = "#{URL}/topics?page=#{page}"
        r = @c.get url
        JSON.parse r.body, symbolize_names: true
    end

    def get_single_topic id
        url = "#{URL}/topics/#{id}"
        r = @c.get url
        JSON.parse r.body, symbolize_names: true
    end

    def get_post id
        url = "#{URL}/posts/#{id}"
        r = @c.get url
        JSON.parse r.body, symbolize_names: true
    end
end
