# -*- coding: utf-8 -*-
require 'arxutils'
require 'flist/dbutil'

module Arxutils
  class Store
    class StoreDb
      def StoreDb.init( hs , block = nil )
        p "= StoreDb.init"
        ret = nil
        register_time = Dbutil::DbMgr.init( hs["db_dir"] , hs["migrate_dir"] , hs["config_dir"], hs["dbconfig"] , hs["log_fname"] )

        if block
          ret = block.call( register_time )
        end
        ret
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
