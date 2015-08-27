# -*- coding: utf-8 -*-
require 'csv'

module Arxutils
  class Store
    class StoreCsv
      def initialize( hs )
        @csv = CSV.open( hs[:csv_fname] , "w" ,
                         { :encoding => hs[:encoding],
                           :headers => hs[:headers],
                           :force_quotes => hs[:force_quotes],
                           :write_headers => hs[:write_headers],
                         } )
      end
    end
  end
end

