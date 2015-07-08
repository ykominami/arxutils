# -*- coding: utf-8 -*-
require 'fileutils'
require 'active_record'
require 'arxutils'
require 'arx_base'
require 'dbutil_base'

module Arxutils
  class Migrate
    def initialize
      @migrate_path = "db/migrate"
      @config_path  = "config"
      FileUtils.mkdir_p( @migrate_path )
      FileUtils.rm( Dir.glob( File.join( @migrate_path , "*")))
      FileUtils.mkdir_p( @config_path )
      FileUtils.rm( Dir.glob( File.join( @config_path , "*")))
      FileUtils.cp( Arxutils.sqlite3yaml , @config_path )
      
      @src_path = Arxutils.templatedir
    end

    def make( next_num , data )
      data[:flist].reduce(next_num) do |idy , x|
        idy += 10
        arx = Arx.new( data , File.join( @src_path , "#{x}.tmpl" ) )
        content = arx.create
        case x
        when "base" , "noitem"
          additional = ""
        else
          additional = x
        end
        fname = File.join( @migrate_path , sprintf("%03d_create_%s%s.rb" , idy , additional , data[:classname_downcase]) )
        File.open( fname , 'w' , {:encoding => Encoding::UTF_8}){ |f|
          f.puts( content )
        }
        idy
      end
    end

    def migrate
      Dbutil::DbMgr.init
      ActiveRecord::Migrator.migrate(@migrate_path ,  ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
    end
  end
end
