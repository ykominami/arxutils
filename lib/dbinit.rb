#! -*- encoding : UTF-8 -*-
require 'yaml'

module Arxutils
  class Dbinit
    def Dbinit.init( config_path: 'config/sqlite3.yaml' , log_fname: 'db/database.log' )
      dbconfig = YAML.load( File.read( config_path ) )
      ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])
      ActiveRecord::Base.logger = Logger.new( log_fname )
    end
  end
end
