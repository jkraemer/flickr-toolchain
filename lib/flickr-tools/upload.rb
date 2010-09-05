require 'flickr-tools/command'
require 'exifr'
require 'iptc/iptc'
require 'pp'

# Uploads an image file to flickr.
# USAGE:
# flickr-tools Upload jk path/to/image
module FlickrTools
  class Upload < Command
  
    def run
      upload @args.shift
    end
  
    def upload(file)
      raise "file not found: #{file}" unless File.readable?(file)
      puts "uploading #{file}"
      uploader = Flickr::Uploader.new @flickr
      pp metadata_of(file)
      # uploader.upload file, {:content_type => :photo, :safety_level => :safe, :privacy => :public, :hidden => false}.merge(metadata_of(file))
    end
    
    protected
    
    def metadata_of(file)
      iptc = iptc(file)
      {
        :title       => iptc["iptc/Headline"].value.first,
        :description => iptc["iptc/Caption"].value.first,
        :tags        => filter_keywords(iptc["iptc/Keywords"].value),
      }
    end
    
    def filter_keywords(keywords)
      keywords - %w(place year)
    end
    
    def iptc(file)
      # $DEBUG=true
      JPEG::Image.new(file).values
    end
    
    def exif(file)
      pp EXIFR::JPEG.new(file).exif
    end
      
  end
end
