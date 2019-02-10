#! -*- encoding : UTF-8 -*-
# coding: utf-8
require 'fileutils'
require 'yaml'
require 'active_record'
#require 'sqlite3'
require 'mysql2'

module Arxutils
  # DB操作用ユーティリティクラス
  module Dbutil
    # DB格納ディレクトリ名
    DB_DIR = 'db'
    # migrate用スクリプト格納ディレクトリ名
    MIGRATE_DIR = 'migrate'
    # SQLITE3用DB構成名
    DBCONFIG_SQLITE3 = 'sqlite3'
    # MYSQL用DB構成名
    DBCONFIG_MYSQL = 'mysql'
    # DB構成格納用ディレクトリ名
    CONFIG_DIR = 'config'
    # データベース用ログファイル名
    DATABASELOG = 'database.log'

    # DB接続までの初期化を行う
    class Dbinit
      # 生成するDB構成情報ファイルパス
      attr_accessor :dbconfig_dest_path
      # 参照用DB構成情報ファイル名
      attr_accessor :dbconfig_src_fname
      # migrate用スクリプトの出力先ディレクトリ名
      attr_accessor :migrate_dir

      # DB接続までの初期化に必要なディレクトリの確認、作成
      def initialize( db_dir , migrate_base_dir , src_config_dir , dbconfig , env, log_fname, opts )
        # DB格納ディレクトリ名
        @db_dir = db_dir
        # DB構成ファイルのテンプレート格納ディレクトリ
        @src_config_dir  = src_config_dir
        # DB構成ファイルの出力先ディレクトリ
        @dest_config_dir  = "config"
        # DB構成ファイル名
        @dbconfig_dest_fname = "#{dbconfig}.yaml"
        # DB構成ファイル用テンプレートファイル名
        @dbconfig_src_fname = "#{dbconfig}.tmpl"
        # DB構成ファイルへのパス
        @dbconfig_dest_path = File.join( @dest_config_dir , @dbconfig_dest_fname)
        # DB構成ファイル用テンプレートファイルへのパス
        @dbconfig_src_path = File.join(@src_config_dir  , @dbconfig_src_fname)
        # 環境の指定
        @env = env
        # DB用ログファイル名
        @log_fname = log_fname
        
        if @db_dir and @log_fname
          # DB用ログファイルへのパス
          @log_path = File.join( @db_dir , @log_fname )
          # migrate用スクリプト格納ディレクトリへのパス
          @migrate_dir = File.join( @db_dir , migrate_base_dir )
        end
        FileUtils.mkdir_p( @db_dir ) if @db_dir
        FileUtils.mkdir_p( @migrate_dir ) if @migrate_dir
        FileUtils.mkdir_p( @dest_config_dir )
        # remigrateが指定されれば、migrate用スクリプトとDB構成ファイルを削除する
        if opts["remigate"]
          FileUtils.rm( Dir.glob( File.join( @migrate_dir , "*"))) if @migrate_dir
          FileUtils.rm( Dir.glob( File.join( @dest_config_dir  , "*")))
        end
      end

      # DB接続し、DB用ログファイルの設定
      def setup
        dbconfig = YAML.load( File.read( @dbconfig_dest_path ) )
        ActiveRecord::Base.establish_connection(dbconfig[@env])
        ActiveRecord::Base.logger = Logger.new( @log_path )
      end
    end
  end
end
