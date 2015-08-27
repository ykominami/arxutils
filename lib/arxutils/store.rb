# -*- coding: utf-8 -*-
require 'arxutils/store/storedb'
require 'arxutils/store/storecsv'

module Arxutils
  class Store
    extend Forwardable

    def Store.init( kind , hs , &block )
      case kind
      when :db
        obj = StoreDb.init( hs , block )
      when :csv
        obj = StoreCsv.new( hs )
      else
        obj = nil
      end

      obj
    end
  end
end
