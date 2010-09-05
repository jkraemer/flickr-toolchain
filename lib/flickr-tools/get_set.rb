require 'flickr-tools/command'

# USAGE:
# flickr-tools GetSet jk
# flickr-tools GetSet jk setname
module FlickrTools
  class GetSet < Command
  
    def run
      set = @args.shift

      if set.nil? || set.blank?
        show_sets
      else
        get_set set
      end
      
    end
    
    def show_sets
      puts "getting sets for #{@name}"
      @flickr.photosets.get_list.each do |set|
        puts set_description(set)
      end
    end
  
    def get_set(id, size = :original)
      if set = find_set(id)
        puts "getting set #{set_description set}"
        dir = set.title.to_filename
        FileUtils.mkdir_p dir
        puts "downloading to #{dir}/"
        per_page = 200
        @queue = Queue.new
        1.upto((set.num_photos.to_i / per_page) + 1) do |page|
          puts "."
          set.get_photos(:page => page, :per_page => per_page).each do |p|
            @queue.enq({ :url => p.url(size), :filename => "#{dir}/#{p.title.to_filename}.jpg" })
          end
        end
        puts "found #{@queue.size} photos"
        spawn_workers
        wait_for_workers
      else
        puts "no set matching #{id} found."
      end
    end
  
    protected
  
    def find_set(id)
      @flickr.photosets.get_list.find{|set| set.id == id || set.title =~ /#{id}/i }
    end
  
    def set_description(set)
      "#{set.id} #{set.title} (#{set.num_photos} photos)"
    end

  
    def spawn_workers(n = 5)
      @workers = []
      n.times do
        t = Thread.new do
          while !@stop && p = @queue.deq
            begin
              puts "downloading #{p[:url]}"
              open( p[:url] ){ |f| (File.open(p[:filename], "w") << f.read).close }
            rescue Exception
              retries = (p[:retries] || 0) + 1
              if retries < 3
                @queue.enq p
              else
                puts "giving up downloading #{p.inspect}:\n#{$!}.message"
              end
            end
          end
        end
        @workers << t
      end
    end
  
    def wait_for_workers
      while !@queue.empty?
        puts "#{@queue.size} items left..."
        sleep 30
      end
      puts "killing workers..."
      @stop = true
      @workers.each { |w| w.join }
      puts "Done."
    end
  
  end
  
end




