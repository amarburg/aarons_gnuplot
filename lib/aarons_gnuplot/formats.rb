

module Gnuplot

  module Formats

    class Format
      def initialize( opts = {} )
      end

      def preamble( plot, outfile )
        plot.terminal terminal
        plot.output outfile.to_s
      end
    end

    class Gnuplot < Format

      def initialize( opts = {} )
        super
      end

      def preamble( plot, outfile )
      end

      def extension; 'gnuplot'; end
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

    module CairoLatex
      class Pdf < Format
        def initialize( options = "", opts = {} )
          super opts
          @options = options
        end

        def terminal
          "cairolatex pdf #{@options}"
        end

        def extension
          "tex"
        end
      end
    end
  end
end



