#!/usr/bin/env ruby

require 'rubygems'

gem 'rubyzip'
gem 'flickr_fu'

require 'optparse'
require 'flickr_fu'
require 'open-uri'
require 'pp'
require 'zip/zipfilesystem'

class String
  def to_filename
    gsub /\W+/, '_'
  end
end

# USAGE:
# get_set auth jk
# get_set sets jk
# get_set jk setname
class GetSet
  
  def initialize(name)
    @name = name
    @flickr = Flickr.new('config/flickr.yml', :token_cache => "config/#{@name}.yml")
  end
  
  def show_sets
    puts "getting sets for #{@name}"
    @flickr.photosets.get_list.each do |set|
      puts set_description(set)
    end
  end
  
  def get_set(id, size = :original)
    @queue = Queue.new

    if set = find_set(id)
      puts "getting set #{set_description set}"
      dir = set.title.to_filename
      FileUtils.mkdir_p dir
      puts "downloading to #{dir}/"
      set.get_photos.each do |p|
        @queue.enq({ :url => p.url(size), :filename => "#{dir}/#{p.title.to_filename}.jpg" })
      end
      spawn_workers
      wait_for_workers
    else
      puts "no set matching #{id} found."
    end
  end
  
  def authorize
    puts "visit the following url, then press <enter> once you have authorized:"
    # request read permissions
    puts @flickr.auth.url(:read)
    gets
    @flickr.auth.cache_token
  end
  
  protected
  
  def find_set(id)
    @flickr.photosets.get_list.find{|set| set.id == id || set.title =~ /#{id}/i }
  end
  
  def set_description(set)
    "#{set.id} #{set.title} (#{set.num_photos} photos)"
  end

  
  def spawn_workers(n = 5)
    @workers = []
    n.times do
      t = Thread.new do
        while !@stop && p = @queue.deq
          begin
            puts "downloading #{p[:url]}"
            open( p[:url] ){ |f| (File.open(p[:filename], "w") << f.read).close }
          rescue Exception
            retries = (p[:retries] || 0) + 1
            if retries < 3
              @queue.enq p
            else
              puts "giving up downloading #{p.inspect}:\n#{$!}.message"
            end
          end
        end
      end
      @workers << t
    end
  end
  
  def wait_for_workers
    while !@queue.empty?
      puts "#{@queue.size} items left..."
      sleep 30
    end
    puts "killing workers..."
    @stop = true
    @workers.each { |w| w.join }
    puts "Done."
  end
  
end





cmd = ARGV.shift
app = nil

if %w(auth sets).include?(cmd)
  user = ARGV.shift
  app = GetSet.new(user)
else
  app = GetSet.new(cmd)
end

case cmd
when 'auth'
  app.authorize
when 'sets'
  app.show_sets 
else
  set = ARGV.shift
  app.get_set set
end
