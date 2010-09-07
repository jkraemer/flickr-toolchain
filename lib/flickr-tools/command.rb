module FlickrTools
  
  class Command
    
    def self.find_config_dir
      config_dir = File.expand_path('../../../config', __FILE__)
      unless File.directory?(config_dir)
        config_dir = File.join(ENV['HOME'], '.flickr-tools')
        FileUtils.mkdir_p config_dir
      end
      return config_dir
    end


    def initialize(argv)
      @config_dir = self.class.find_config_dir
      @args = argv.dup
      @name = @args.shift
      @token_cache = File.join(@config_dir, "#{@name}.yml")
      @flickr_yml = File.join @config_dir, 'flickr.yml'
      unless File.readable?(@flickr_yml)
        FileUtils.cp File.expand_path('../../../doc/flickr.yml.example', __FILE__), @flickr_yml
        puts "Please get a flickr API key and secret from flickr.com and edit #{@flickr_yml} accordingly."
        exit 1
      end
    end
    
    protected
    
    def flickr
      @flickr ||= Flickr.new(@flickr_yml, :token_cache => @token_cache)
    end
    

    
  end
  
end
