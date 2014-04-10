require 'gnuplot'
require_relative 'formats'

module Gnuplot

  def self.do_plot( filename, format = nil, &blk )
      Gnuplot.open do |gp|
         plot = Gnuplot::Plot.to_file( gp, filename, format ) do |plot|
                     blk.call plot
                   end

         if format.save_gnuplot?
           filename = plot["output"].gsub(/"/,'') + ".gnuplot"
           puts "Wrote gnuplot to #{filename}"
           File.open( filename, "w" ) { |io|
             io << plot.to_gplot
             io << plot.store_datasets
           }
         end
      end
  end

  class Plot

    class <<self
      def format
        @format || SVG.new
      end

      def format=(s)
        @format = s
      end

      def output_dir
        @output_dir || Pathname.new("/tmp")
      end

      def output_dir=(s)
        @output_dir = Pathname.new(s)
      end

      def timestamp_titles?; @timestamp_titles; end
      def timestamp_titles=(s); @timestamp_titles=s; end

    end

    def self.to_file( gp, file, format = nil, &blk )
      format ||= Plot::format

      file += ".#{format.extension}" unless File::extname( file ).length > 0
      file = Plot.output_dir.join(file).to_s unless file.match "/"

      Gnuplot::Plot.new(gp) do |plot|

        plot.terminal format.terminal
        outfile = file
        raise "Output dir \"#{File.dirname(outfile)}\" doesn't exist" unless File.directory? File.dirname( outfile )
        File::open(outfile, "w" ) {}
        plot.output outfile

        blk.call( plot )

      end
    end


    def with_labels( x, pt_opts = "" )
      data << Gnuplot::DataSet.new( x[0..1] ) do |ds|
        ds.with = ["points", pt_opts].join(' ')
        ds.notitle
      end
      data << Gnuplot::DataSet.new( x[0..2] ) do |ds|
        ds.with = "labels offset 0,1"
        ds.notitle
      end

    end
    
    def histogram
      set "style", "data histograms"
      set "bars", "fullwidth"
      set "xtics", "nomirror rotate by -45 scale 0 font \",8\""
      set "style", "fill solid 1 border lt -1"
      set "grid", "ytics"
    end

    def histogram_with_errorbars
      histogram
      set "style", "histogram errorbars"
    end

    #alias :original_title :title
    def title(s)
      t = if Plot.timestamp_titles?
            s + " -- #{Time.now.strftime("%F %T")}"
          else
            s
          end 
      set "title", t
    end

  end
end
