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
  end
end
