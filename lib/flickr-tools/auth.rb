require 'flickr-tools/command'

module FlickrTools
  
  # USAGE:
  # flickr-tools Auth username
  # 
  # the username argument is just a shorthand to identify the same user in further calls to other flickr-tools commands, must not equal your flickr username.
  class Auth < Command
    
    def initialize(argv)
      FileUtils.rm File.join(self.class.find_config_dir, "#{argv[0]}.yml")
      super
    end
    
    def run
      authorize
    end
    
    def authorize
      puts "visit the following url, then press <enter> once you have authorized:"
      # request permissions
      puts @flickr.auth.url(:write)
      STDIN.gets
      @flickr.auth.cache_token
    end
    
  end
end