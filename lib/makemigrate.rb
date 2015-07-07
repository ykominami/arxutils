# -*- coding: utf-8 -*-
require 'fileutils'
require 'arxutils'

module Arxutils
  class Migrate
    def initialize
      migrate_path = "db/migrate"
      FileUtils.mkdir_p( migrate_path )
      FileUtils.rm( Dir.glob( File.join( migrate_path , "*")))
      src_path = Arxutils.dirname
    end

    def migrate( carray , &block)
      if block_given
        carray.reduce(0) do |idx , x|
          block.call(idx, x)
        end
      end
      carray.reduce(0) do |idx , x|
      end
    end
    
    def make( dir_path , src_path, idx , filist )
      #  %W!base invalid current!.reduce(idx) do |idy , x|
      filist.reduce(idx) do |idy , x|
        idy += 10
        arx = Arx.new( File.join( src_path , "#{x}.tmpl" ) )
        content = arx.create
        case x
        when "base" , "noitem"
          additional = ""
        else
          additional = x
        end
        fname = File.join( dir_path , sprintf("%03d_create_%s%s.rb" , idy , additional , arx.classname_downcase) )
        File.open( fname , 'w' , {:encoding => Encoding::UTF_8}){ |f|
          f.puts( content )
        }
        idy
      end
    end
  end
end




