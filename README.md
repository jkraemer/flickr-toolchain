Flickr toolchain
================

Collection of simple command line tools I use to handle my flickr needs.

Use at your own risk, ymmv.

Authorization
-------------

First of all you need to get an API key at flickr.com. Put the key and the secret into ~/.flickr-tools/flickr.yml:

  key: your-flickr-api-key
  secret: your-flickr-secret
  token_cache: token_cache.yml


Now call

  flickr-tools Auth username

This will prompt you to visit an URL at flickr.com to authorize write access for the application. Do so and press Enter.
The token received from flickr will be stored in ~/.flickr-tools/username.yml for further use.



Listing sets
------------

  flickr-tools GetSet username

will list all sets in your flickr account.
  

Download whole set
------------------

  flickr-tools GetSet username setname
  
Use this command to download all pictures (in 'original' size) of the named set. The result is a single zip file containing all images.
You can use the set id (as printed out by the set listing from above) or a fragment/regexp matching the set title. The first matching 
set will be exported.


Upload Picture
--------------

  flickr-tools Upload username /path/to/picture
  
I intend to use this command to directly upload images to flickr from a batch output queue in [Bibble](http://bibblelabs.com/).
Flickr metadata (privacy, tags, title, description) is extracted from iptc metadata contained in the picture. See lib/flickr-tools/upload.rb
for how it's mapped (and modify to suit your needs).

NOTE: Upload doesn't work, seems I'll have to fix flickr_fu first to make it work...

