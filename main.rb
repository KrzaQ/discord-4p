#!/usr/bin/ruby
require_relative 'opts'
require_relative 'db'
require_relative 'four_programmers'
require_relative 'discord'

require 'sequel'
require 'sqlite3'
require 'time'

OPTS = load_opts

class Bot

    def initialize opts
        @opts = opts
        @db_connection = nil
    end

    def exec
        begin
            self.send 'action_%{action}' % @opts
        rescue NoMethodError => e
            p e
            action_help 'Action \'%{action}\' not found.' % @opts
        rescue => e
            puts "Failure! Backtrace: "
            puts e.backtrace
            action_help e.message
        end
    end

    def db
        return @db_connection if @db_connection
        @db_connection = Sequel.connect({
            adapter: 'sqlite',
            database: @opts[:database_file],
        })
    end

    def action_help msg = nil
        puts "Error: %s" % msg if msg
        puts make_parser
    end

    def action_init_database
        create_tables db
    end

    def action_add_hook
        hook = @opts[:hook]
        channel = @opts[:channel]
        raise "Hook and channel must be specified." unless hook and channel
        db[:hooks].insert channel: channel, value: hook
    end

    def action_add_tag
        tag = @opts[:tag]
        channel = @opts[:channel]
        raise "Tag and channel must be specified." unless tag and channel
        db[:tags].insert channel: channel, tag: tag
    end

    def action_add_category
        category = @opts[:category]
        channel = @opts[:channel]
        raise "Category and channel must be specified." unless category and channel
        db[:categories].insert channel: channel, category: category
    end

    def action_get4p
        fp = FourProgrammers.new

        tags = db[:tags].all.map(&:to_hash)
            .map{ [_1[:tag], _1[:channel]] }
            .to_h
        categories = db[:categories].all.map(&:to_hash)
            .map{ [_1[:category], _1[:channel]] }
            .to_h

        topics = fp.get_topics_since(get_last_id).sort_by{ _1[:id] }
        topics.each do |t|
            puts "[%s] %6d: '%s' (%s)" % [
                Time.now.strftime('%H:%M:%S'),
                t[:id],
                t[:subject],
                t[:tags].map{ _1[:name] }.join(", "),
            ]
            channels = t[:tags].map{ tags[_1[:name].downcase] }
            channels.push categories[t[:forum][:name].downcase]
            channels = channels.compact.uniq
            if channels.size > 0
                post = fp.get_post t[:first_post_id]
                channels.each{ send_to_discord t, post, _1 }
            end
            set_last_id t[:id]
        end
    end

    def get_last_id
        r = db[:registry].first(key: 'last_topic_id')
        r ? r[:value].to_i : nil
    end

    def set_last_id id
        db[:registry].insert_conflict(:replace).insert({
            key: 'last_topic_id',
            value: id
        })
    end

    def send_to_discord topic, post, channel
        hook = db[:hooks].first(channel: channel)[:value]
        Discord.new.send topic, post, hook
    end

    def action_test
        fp = FourProgrammers.new
        # t = fp.get_single_topic 353310
        t = fp.get_single_topic 353575
        post = fp.get_post t[:first_post_id]
        send_to_discord t, post, '#cpp'
    end

end

Bot.new(OPTS).exec
