require 'flickr_fu'
# require 'exifr'
require 'iptc'
require 'pp'

require 'flickr-tools/command'

module FlickrTools
  
  # Upload one or more image files to flickr.
  #
  # USAGE:
  # flickr-tools Upload jk path/to/image ...
  #
  # Flickr metadata is determined from the picture's IPTC metadata:
  # title       - iptc/Headline
  # description - iptc/Caption
  # tags        - iptc/Keywords minus IGNORE_KEYWORDS and PRIVACY_KEYWORDS
  # privacy     - privacy level is set to the given PRIVACY_KEYWORD if also the 'privacy' keyword is present in iptc keywords, public otherwise.
  #
  # The keyword-to-tags treatment might seem strange, the reason is that Bibble uses hierarchical keyword trees which get flattened when written 
  # to IPTC meta data. That's why my pictures have these abstract first level keywords like 'place' and 'year' which I don't want to appear on flickr.
  class Upload < Command
  
    # list of keywords not to be used as flickr tags
    IGNORE_KEYWORDS  = %w(place year privacy subject)
    
    # list of keywords used to determine the flickr privacy level. Photos are public by default.
    PRIVACY_KEYWORDS = %w(private friends family friends_and_family)
    
    def run
      @uploader = Flickr::Uploader.new flickr      
      @args.each { |f| upload_file f }
      puts "done."
    end
    
    protected

    def upload_file(file)
      if File.readable?(file)
        meta = { :content_type => :photo, :safety_level => :safe, :hidden => false }.merge(metadata_for(file))
        puts "uploading #{file} with\n#{meta.inspect}"
        response = @uploader.upload file, meta
        options = { :photo_id => response.photoid, :tags => meta[:tags] }
        flickr.send_request('flickr.photos.setTags', options, :post)
      else
        puts "file not found: #{file}" 
      end
    rescue Exception
      puts "Error uploading #{file}: #{$!}\n#{$!.backtrace.join("\n")}"
    end
    
    def metadata_for(file)
      iptc = iptc(file)
      keywords = iptc["iptc/Keywords"].value rescue ''
      {
        :title       => (iptc["iptc/Headline"].value.first rescue File.basename(file)),
        :description => (iptc["iptc/Caption"].value.first rescue ''),
        :tags        => keywords_to_tags(keywords).join(' '),
        :privacy     => privacy(keywords)
      }
    end
    
    def privacy(keywords)
      privacy = ((keywords.include?('privacy') ? (keywords & PRIVACY_KEYWORDS).first : nil ) || 'public').to_sym
    end
    
    def keywords_to_tags(keywords)
      keywords.map(&:downcase) - IGNORE_KEYWORDS - PRIVACY_KEYWORDS
    end
    
    def iptc(file)
      IPTC::JPEG::Image.new(file).values
    end
    
    # def exif(file)
    #   pp EXIFR::JPEG.new(file).exif
    # end
      
  end
end
