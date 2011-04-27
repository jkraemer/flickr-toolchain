require 'flickr-tools/command'

module FlickrTools
  
  # USAGE:
  # flickr-tools Auth username
  # 
  # the username argument is just a shorthand to identify the same user in further calls to other flickr-tools commands, must not equal your flickr username.
  class Auth < Command
    
    def run
      authorize
    end
        
    def check_token(required_perms = :write)
      res = flickr.auth.check_token
      allowed_perms = case required_perms
      when :read
        %w(read write delete)
      when :write
        %w(write delete)
      when :delete
        %w(delete)
      end
      perm = res.auth.perms.to_s
      if allowed_perms.include?(perm)
        true
      else
        puts "insufficient permissions: #{perm}, required was: #{required_perms}"
        false
      end
    rescue Exception
      puts "check_token failed: #{$!}\n#{$!.backtrace.join("\n")}"
      # authorize
    end
    
    
    def authorize
      @flickr = nil
      FileUtils.rm_f @token_cache
      puts "please visit the following url, then press <enter> once you have authorized:"
      # request permissions
      puts flickr.auth.url(:write)
      STDIN.gets
      flickr.auth.cache_token
    end
    
  end
end
