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

class GetSet
  
  def initialize(name)
    @name = name
    @flickr = Flickr.new('flickr.yml', :token_cache => "#{@name}.yml")
  end
  
  def show_sets
    puts "getting sets for #{@name}"
    @flickr.photosets.get_list.each do |set|
      puts set_description(set)
    end
  end
  
  def get_set(id, size = :original)
    if set = find_set(id)
      puts "getting set #{set_description set}"
      
      set.get_photos.each do |p|
        puts  "#{p.title} #{p.url(size)}"
        Zip::ZipFile.open("#{set.title.to_filename}.zip", Zip::ZipFile::CREATE) do |zipfile|
          zipfile.file.open("#{p.title.to_filename}.jpg", "w") do |photo|
            open( p.url(size) ){ |f| photo << f.read }
          end
        end
      end
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
  
end




# get_set auth jk
# get_set sets jk
# get_set jk setname


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
