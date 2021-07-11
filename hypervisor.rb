#!/usr/bin/ruby
require 'optparse'

def load_opts
    opts = {
        delay: 5.0,
        command: './main.rb',
    }

    OptionParser.new do |o|
        o.on('--delay delay'){ |c| opts[:delay] = Float(c) }
        o.on('--command CMD'){ |c| opts[:command] = c }
    end.parse!

    opts
end

OPTS = load_opts

while true do
    b = Time.now
    system(OPTS[:command])
    e = Time.now
    to_sleep = [OPTS[:delay] - (e-b), 0].max
    sleep to_sleep
end
