# -*- coding: utf-8 -*-
require 'erb'

module Arxutils
  class Arx
    def initialize( data , fname )
      @fname = fname
      # 以下のものの配列
      # :flist
      # :classname
      # :classname_downcase
      # :items
      #  フィールド名, 型, null許容 の配列
      # :plural
      @data = data

      @@field ||= Struct.new("Field" , :name, :type, :null ) 

      @data[:ary] = @data[:items].map{ |x| @@field.new( *x ) }
    end

    def create
      contents = File.open( @fname ).read

      erb = ERB.new(contents)
      erb.result(binding)
    end

    def update_integer( model , hs )
      value_hs = hs.reduce({}){ |hsx,item|
        val = model.send(item[0])
        if val != nil and item[1] != nil and val  < item[1]
          hsx[ item[0] ] = item[1]
        end
        hsx
      }
      model.update(value_hs) if value_hs.size > 0
    end

  end
end
