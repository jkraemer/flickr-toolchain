module FlickrTools
  
  class Command
    
    def initialize(argv)
      @config_dir = self.class.find_config_dir
      @args = argv.dup
      @name = @args.shift
      flickr_yml = File.join @config_dir, 'flickr.yml'
      unless File.readable?(flickr_yml)
        FileUtils.cp File.expand_path('../../../doc/flickr.yml.example', __FILE__), flickr_yml
        puts "Please get a flickr API key and secret from flickr.com and edit #{flickr_yml} accordingly."
        exit 1
      end
      @flickr = Flickr.new(flickr_yml, :token_cache => File.join(@config_dir, "#{@name}.yml"))
    end


    def self.find_config_dir
      config_dir = File.expand_path('../../..', __FILE__)
      unless File.directory?(File.join(config_dir, 'config'))
        config_dir = File.join(ENV['HOME'], '.flickr-tools')
        FileUtils.mkdir_p config_dir
      end
      return config_dir
    end
    
  end
  
end
