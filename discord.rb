require 'httpclient'
require 'json'

class Discord

    def initialize
        @c = HTTPClient.new
    end

    def send topic, post, hook
        msg = make_message topic
        headers = { 'Content-Type': 'application/json' }
        body = {
            # content: make_message(topic),
            content: "#{get_emoji(topic, post)} **Nowy temat**",
            embeds: [ make_embed(topic, post) ],
        }
        r = @c.post hook, body.to_json, headers
        p r.body
    end

    def update message_id, topic, post, hook
        raise "Not implemented"
    end

    def topic_url data
        "https://4programmers.net/Forum/#{data[:first_post_id]}"
    end

    def get_emoji topic, post
        m = {
            'zkubinski' => '<:troll:862014139219050507>'
        }
        m.fetch(post[:user][:name], ':bell:')
    end

    def make_embed topic, post
        tags_str = topic[:tags].map{ '`%{name}`' % _1 }.join(", ")
        author = {
            name: post[:user][:name]
        }
        p post[:excerpt]
        author[:icon_url] = post[:user][:photo] if post[:user][:photo]
        r = {
            title: topic[:subject],
            url: topic_url(topic),
            description: post[:excerpt],
            color: 9944589,
            author: author,
            fields: [
                {
                    name: 'Forum',
                    value: topic[:forum][:name],
                    inline: true,
                },
                {
                    name: 'Tags',
                    value: tags_str,
                    inline: true,
                },
            ],
        }
        r
    end

    def make_message data
        forum = "[#{data[:forum][:name]}]"
        topic = "**#{data[:subject]}**"
        tags_str = data[:tags].map{ '`%{name}`' % _1 }.join(", ")
        tags = "(#{tags_str})"
        link = "<#{topic_url data}>"

        msg = "`%s` %s\n%s %s" % [forum, topic, link, tags]
    end

end
