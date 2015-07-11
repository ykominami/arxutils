#! -*- encoding : UTF-8 -*-
require 'yaml'

module Arxutils
  DB_DIR = 'db'
  MIGRATE_DIR = 'db/migrate'
  DBCONFIG = 'sqlite3.yaml'
  CONFIG_DIR = 'config'
  DATABASELOG = 'database.log'
  
  class Dbinit
    attr_accessor :dbconfig_dest_path
    
    def initialize( db_dir , migrate_dir , config_dir , dbconfig, log_fname, forced = false )
      @db_dir = db_dir
      @migrate_dir = migrate_dir
      @config_dir  = config_dir
      @dbconfig = dbconfig
      @log_fname = log_fname
      @log_path = File.join( @db_dir , @log_fname )
      @dbconfig_dest_path = File.join( @config_dir , @dbconfig )
      FileUtils.mkdir_p( @db_dir )
      FileUtils.mkdir_p( @migrate_dir )
      FileUtils.mkdir_p( @config_path )
      if forced
        FileUtils.rm( Dir.glob( File.join( @migrate_dir , "*")))
        FileUtils.rm( Dir.glob( File.join( @config_dir  , "*")))
        dbconfig_src_path = File.join( Arxutils.configdir, dbconfig )
        FileUtils.cp( dbconfig_src_path , @dbconfig_dest_path )
      end
    end
    
    def setup
      dbconfig = YAML.load( File.read( @dbconfig_dest_path ) )
      ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])
      ActiveRecord::Base.logger = Logger.new( @log_path )
    end

  end
end
