module FlickrTools
  
  # flickr-tools Auth jk
  class Auth < Command
    
    def run
      authorize
    end
    
    def authorize
      puts "visit the following url, then press <enter> once you have authorized:"
      # request read permissions
      puts @flickr.auth.url(:write)
      gets
      @flickr.auth.cache_token
    end
    
  end
end