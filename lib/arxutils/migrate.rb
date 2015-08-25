# -*- coding: utf-8 -*-
require 'arxutils'

require 'fileutils'
require 'active_record'

module Arxutils
  class Migrate
    attr_accessor :dbinit , :dbconfig_dest_path , :dbconfig_dest_fname , :dbconfig_src_path , :dbconfig_src_fname
    
    def Migrate.migrate( data_ary , idx , dbconfig , forced )
      src_config_dir = Arxutils.configdir
      mig = Migrate.new(Dbutil::DB_DIR, Dbutil::MIGRATE_DIR , src_config_dir , dbconfig, Dbutil::DATABASELOG, forced )
      mig.make_dbconfig( data_ary[idx] )
      
      data_ary.reduce(0) do |next_num , x| 
        mig.make( next_num , x )
      end

      Dbutil::DbMgr.setup( mig.dbinit )

      mig.migrate
    end
    
    def initialize( db_dir , migrate_dir , config_dir , dbconfig, log_fname, forced = false )
      @dbinit = Dbutil::Dbinit.new( db_dir , migrate_dir , config_dir , dbconfig, log_fname, forced )
      @dbconfig_dest_path = @dbinit.dbconfig_dest_path
      @dbconfig_src_path = @dbinit.dbconfig_src_path
      @dbconfig_src_fname = @dbinit.dbconfig_src_fname

      @migrate_dir = migrate_dir
      @src_path = Arxutils.templatedir
      @src_config_path = Arxutils.configdir
    end

    def convert( data , src_dir , src_fname )
      arx = Arx.new( data , File.join( src_dir, src_fname ) )
      arx.create
    end
    
    def make_dbconfig( data )
      content = convert( data , @src_config_path , @dbconfig_src_fname )
      File.open( @dbconfig_dest_path , 'w' , {:encoding => Encoding::UTF_8}){ |f|
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
        p fname
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
