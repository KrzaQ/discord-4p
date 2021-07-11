require 'optparse'

def make_parser opts = {}
    OptionParser.new do |o|
        o.on('-aA', '--action ACTION'){ opts[:action] = _1 }
        o.on('--hook URL'){ opts[:hook] = _1 }
        o.on('--tag TAG'){ opts[:tag] = _1 }
        o.on('--category CATEGORY'){ opts[:category] = _1 }
        o.on('--channel CHANNEL'){ opts[:channel] = _1 }
        o.on('--topic TOPIC'){ opts[:topic] = _1 }
        o.on('--database_file FILE'){ opts[:database_file] = _1 }
    end
end

def load_opts
    opts = {
        database_file: 'bot.sqlite',
        action: :help,
    }

    make_parser(opts).parse!

    opts
end
