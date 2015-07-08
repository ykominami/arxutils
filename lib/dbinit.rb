#! -*- encoding : UTF-8 -*-

module Arxutils
  class Dbinit
    def Dbinit.init( config_path , log_fname )
      dbconfig = YAML.load( File.read( config_path ) )
      ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])
      ActiveRecord::Base.logger = Logger.new( log_fname )
    end
  end
end
