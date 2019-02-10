# -*- coding: utf-8 -*-
require 'erb'

module Arxutils
  # スキーマ設定に基づき、テンプレートから変換する
  class Arx
    # スキーマ設定配列を、テンプレートで参照可能になるように展開する
    def initialize( data , fname )
      # テンプレートファイルへのパス
      @fname = fname

      # スキーマ設定配列
      # スキーマ設定とは以下をキーにもつハッシュである
      # :flist
      # :classname
      # :classname_downcase
      # :items
      #  フィールド名, 型, null許容 の配列
      # :plural
      # :relation
      @data = data

      # スキーマ設定の:itemsの値を展開後格納するためのStructクラス
      @@field ||= Struct.new("Field" , :name, :type, :null ) 

      if @data[:items]
        @data[:ary] = @data[:items].map{ |x| @@field.new( *x ) }
      else
        @data[:ary] = []
      end
    end

    # テンプレートファイルを元にした変換結果を返す
    def create
      contents = File.open( @fname ).read
      erb = ERB.new(contents)
      content = erb.result(binding)
      content
    end

  end
end
