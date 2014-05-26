require 'gnuplot'
require_relative 'formats'

module Gnuplot

  def self.do_plot( filename, format = nil, &blk )

    outfile = Gnuplot::Plot::check_filename( filename, format )
    puts "Writing #{format.class.to_s.split('::').last} to #{outfile}"

    case format
    when Formats::Gnuplot
      File.open( outfile, "w" ) do |io|
        Gnuplot::Plot.to_file( io, outfile, format, &blk )
      end 
    else
      Gnuplot.open do |gp|
        Gnuplot::Plot.to_file( gp, outfile, format, &blk )
      end
    end
  end

  class Plot

    include Formats

    class <<self
      def format
        @format || Formats::SVG.new
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

      def check_filename( filename, format = Plot::format )
        filename = Pathname.new( filename )
        filename = filename.sub_ext(".#{format.extension}") unless filename.extname.length > 0
        outfile = filename.to_s.match("/") ? filename : Plot.output_dir.join(filename).to_s 
        raise "Output dir \"#{outfile.dirname}\" doesn't exist" unless outfile.dirname.directory?
        outfile
      end
    end

    def self.to_file( io, filename, format = nil, &blk )
      format ||= Plot::format
      outfile = check_filename( filename, format )

      Gnuplot::Plot.new(io) do |plot|

        format.preamble( plot, outfile )
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
