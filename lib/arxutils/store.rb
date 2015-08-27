# -*- coding: utf-8 -*-
require 'arxutils/store/storedb'
require 'arxutils/store/storecsv'

module Arxutils
  class Store
    extend Forwardable

    def initialize( kind , hs )
      case kind
      when :db
        obj = StoreDb.new( hs )
      when :CSV
        obj = StoreCsv.new( hs )
      else
        obj = nil
      end

      obj
    end
  end
end
