#! -*- encoding : UTF-8 -*-
require 'fileutils'
require 'yaml'
require 'active_record'
require 'sqlite3'

module Arxutils
  module Dbutil
    DB_DIR = 'db'
    MIGRATE_DIR = 'db/migrate'
    DBCONFIG_SQLITE3 = 'sqlite3'
    DBCONFIG_MYSQL = 'mysql'
    CONFIG_DIR = 'config'
    DATABASELOG = 'database.log'
    
    class Dbinit
      attr_accessor :dbconfig_dest_path , :dbconfig_src_path , :dbconfig_src_fname , :dbconfig_dest_fname 
      
      def initialize( db_dir , migrate_dir , src_config_dir , dbconfig , log_fname, forced = false )
        @db_dir = db_dir
        @migrate_dir = migrate_dir
        @src_config_dir  = src_config_dir
        @dest_config_dir  = "config"
        @dbconfig_dest_fname = "#{dbconfig}.yaml"
        @dbconfig_src_fname = "#{dbconfig}.tmpl"
        @dbconfig_dest_path = File.join( @dest_config_dir , @dbconfig_dest_fname)
        @dbconfig_src_path = File.join(@src_config_dir  , @dbconfig_src_fname)
        @log_fname = log_fname
        @log_path = File.join( @db_dir , @log_fname )
        FileUtils.mkdir_p( @db_dir )
        FileUtils.mkdir_p( @migrate_dir )
        FileUtils.mkdir_p( @dest_config_dir )
        if forced
          FileUtils.rm( Dir.glob( File.join( @migrate_dir , "*")))
          FileUtils.rm( Dir.glob( File.join( @dest_config_dir  , "*")))
        end
      end
      
      def setup
        puts ENV['ENV']
        dbconfig = YAML.load( File.read( @dbconfig_dest_path ) )
        puts dbconfig[ ENV['ENV'] ]
        ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])
        ActiveRecord::Base.logger = Logger.new( @log_path )
      end
    end
  end
end
