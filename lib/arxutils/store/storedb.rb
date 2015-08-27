# -*- coding: utf-8 -*-
require 'arxutils'

module Arxutils
  class Store
    class StoreDb
      def initialize( hs , &block )
        register_time = Arxutils::Dbutil::DbMgr.init( hs["db_dir"] , hs["migrate_dir"] , hs["config_dir"], hs["dbconfig"] , hs["log_fname"] )

        if block_given?
          @dbmgr = block.call( register_time )
        end
      end
      # hs
      # :csv_fname
      # :mode
      # :encoding => 'UTF-8',
      # :headers => @headers_s,
      # :force_quotes => true,
      # :write_headers => true,
    end
  end
end
