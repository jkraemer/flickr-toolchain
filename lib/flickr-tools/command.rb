module FlickrTools
  
  class Command
    
    def initialize(argv)
      config_dir = File.expand_path('../../..', __FILE__), 'config'
      unless File.directory?(File.join(config_dir, 'config'))
        config_dir = File.join(ENV['HOME'], '.flickr-tools')
        FileUtils.mkdir_p config_dir
      end
      @args = argv.dup
      @name = @args.shift
      @flickr = Flickr.new(File.join(config_dir, 'flickr.yml'), :token_cache => File.join(config_dir, "#{@name}.yml"))
    end
    
    
  end
  
end
