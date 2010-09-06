require 'flickr-tools/command'
# require 'exifr'
require 'iptc'
require 'pp'

module FlickrTools
  
  # Upload an image file to flickr.
  #
  # USAGE:
  # flickr-tools Upload jk path/to/image
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
      upload @args.shift
    end
  
    def upload(file)
      raise "file not found: #{file}" unless File.readable?(file)
      puts "uploading #{file}"
      uploader = Flickr::Uploader.new @flickr
      pp metadata_for(file)
      # uploader.upload file, {:content_type => :photo, :safety_level => :safe, :hidden => false}.merge(metadata_for(file))
    end
    
    protected
    
    def metadata_for(file)
      iptc = iptc(file)
      keywords = iptc["iptc/Keywords"].value
      privacy = ((keywords.include?('privacy') ? keywords.intersect(PRIVACY_KEYWORDS).first : nil ) || 'public').to_sym
      
      {
        :title       => iptc["iptc/Headline"].value.first,
        :description => iptc["iptc/Caption"].value.first,
        :tags        => keywords_to_tags(keywords),
        :privacy     => privacy
      }
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
