module IPTC
    # == Marker
    # A simple IPTC Marker
    class Marker
        attr_accessor :value
        def initialize(type, value)
            @type = type
            @value = value
        end
        def to_s
            self.value
        end
        def to_binary
            "\x1c\x02"+[@type, @value.length].pack('cn')+@value
        end        
    end
    
    require 'singleton'
    
    class MarkerNomenclature
      include Singleton
      def MarkerNomenclature.markers(id)
        return MarkerNomenclature.instance.markers(id)
      end
      
      def markers(id)
        if @markers.has_key?(id)
          return @markers[id]
        else
          return @markers[-1]
        end
      end
      
      def populate
        @markers = {}
        begin
          fullpath = nil
          
          [File.dirname(__FILE__), $:].flatten.each { |path|
            break if File.exists?(fullpath = File.join(path, "iptc"))
          }
          content = File.open(fullpath).read
        rescue Exception=>e
          raise "Load failed for \"iptc\" file\nWith $:=#{$:.inspect}\n\n"+e
        end
        marker = Struct.new(:iid, :name, :description)
        
        m = marker.new
        m.name = "Unknow marker"
        m.iid = -1
        @markers[-1] = m
                
        content.each_line do |line|
            tags = line.split(/\t/)
            m = marker.new
            m[:name] = tags[0]
            m[:description] = tags[1]
            m[:iid] = tags[2].to_i
            @markers[m.iid] = m
        end
      end
    end
    MarkerNomenclature.instance.populate
end
