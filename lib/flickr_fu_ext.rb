require 'flickr_fu'

module Flickr
  class Auth
    def check_token
      rsp = @flickr.send_request('flickr.auth.checkToken')
      if rsp[:stat] == 'ok'
        rsp
      else
        raise "#{rsp.err[:code]}: #{rsp.err[:msg]}"
      end
    end
  end
end