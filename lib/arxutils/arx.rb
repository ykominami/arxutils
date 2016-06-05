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
      # :relation
      @data = data

      @@field ||= Struct.new("Field" , :name, :type, :null ) 

      if @data[:items]
        @data[:ary] = @data[:items].map{ |x| @@field.new( *x ) }
      else
        @data[:ary] = []
      end
    end

    def create
      contents = File.open( @fname ).read
      erb = ERB.new(contents)
      content = erb.result(binding)
      content
    end

  end
end
