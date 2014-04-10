

module Gnuplot

  class Plot

    class Format
      attr_writer :save_gnuplot
      def initialize( opts = {} )
        @save_gnuplot = opts[:save_gnuplot] || false
      end

      def save_gnuplot?
        @save_gnuplot
      end
    end

    class Postscript < Format
      def terminal
        "postscript"
      end

      def extension
        "ps"
      end
    end
    def self.Postscript( *args ); Postscript.new( *args ); end

    class EnhancedPostscript < Postscript
      def initialize( options = "", opts = {} )
        super opts
        @opts = options
      end

      def terminal
        "postscript eps enhanced color #{@opts}"
      end

      def extension
        "eps"
      end
    end
    def self.EnhancedPostscript( *args ); EnhancedPostscript.new( *args ); end


    class SVG < Format
      def terminal
        "svg size 1280,1024"
      end
      def extension
        'svg'
      end
    end
  end
end



