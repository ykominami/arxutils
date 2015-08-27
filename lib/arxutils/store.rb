# -*- coding: utf-8 -*-
require 'arxutils/store/sotredb'
require 'arxutils/store/sotrecsv'

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
