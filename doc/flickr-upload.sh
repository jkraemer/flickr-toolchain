#!/bin/bash

# sample shell script to be called from asset management programs like bibble
# takes the filename as argument

source $HOME/.rvm/scripts/rvm
rvm use 1.9.2 
flickr-tools Upload jk $1 >> /Users/jk/Pictures/flickr_upload/log 2>&1

