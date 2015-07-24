# -*- coding: utf-8 -*-
require 'arxutils'
require 'arx_base'
require 'dbutil_base'
require 'dbinit'

require 'fileutils'
require 'active_record'

module Arxutils
  class Migrate
    def Migrate.migrate( data_ary , idx , dbconfig , forced )
      config_dir = Arxutils.configdir
      mig = Migrate.new(DB_DIR, MIGRATE_DIR , config_dir , DATABASELOG, forced )
      make_dbconfig( data_ary[idx] , dbconfig )
      
      data_ary.reduce(0) do |next_num , x| 
        mig.make( next_num , x )
      end

      mig.migrate
    end
    
    def initialize( db_dir , migrate_dir , config_dir , log_fname, forced = false )
      Dbutil::DbMgr.init( db_dir , migrate_dir , config_dir , log_fname, forced )
      @migrate_dir = migrate_dir
      @src_path = Arxutils.templatedir
      @config_path = Arxutils.configdir
    end

    def convert( data , src_dir , src_fname )
      arx = Arx.new( data , File.join( @config_path , "mysql.tmpl" ) )
      arx.create
    end
    def make_dbconfig( data , kind )
      convert( data , @config_path , "#{kind}.tmpl" )
      fname = File.join( @migrate_dir , sprintf("%03d_create_%s%s.rb" , idy , additional , data[:classname_downcase]) )
      File.open( fname , 'w' , {:encoding => Encoding::UTF_8}){ |f|
        f.puts( content )
      }
    end
    
    def make( next_num , data )
      data[:flist].reduce(next_num) do |idy , x|
        idy += 10
        content = convert( data , @src_path , "#{x}.tmpl" )
        case x
        when "base" , "noitem"
          additional = ""
        else
          additional = x
        end
        fname = File.join( @migrate_dir , sprintf("%03d_create_%s%s.rb" , idy , additional , data[:classname_downcase]) )
        File.open( fname , 'w' , {:encoding => Encoding::UTF_8}){ |f|
          f.puts( content )
        }
        idy
      end
    end

    def migrate
      ActiveRecord::Migrator.migrate(@migrate_dir ,  ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
    end
  end
end
