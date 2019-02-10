# -*- coding: utf-8 -*-

module Arxutils
  # モジュールArxutils内でのユーティリティクラス
  class Arxutils
    # モジュールArxutils内のテンプレートファイル格納ディレクトリへのパスを返す
    def self.templatedir
      File.join(  Arxutils.dirname , ".." , "template" )
    end

    # モジュールArxutils内の構成情報格納ディレクトリへのパスを返す
    def self.configdir
      File.join( Arxutils.dirname  , ".." , 'config' )
    end

  private
    # モジュールArxutils内のlib/arxutilsディレクトリへのパスを返す
    def self.dirname
      File.dirname( __FILE__ )
    end
  end
end
