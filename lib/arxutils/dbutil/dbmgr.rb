# -*- coding: utf-8 -*-

require 'arxutils/dbutil/dbinit'
require 'date'
require 'pp'

module Arxutils
  module Dbutil
    # DB接続時に、現在日時も取得したい場合のユーティリティクラス
    class DbMgr
      # Dbinitクラスのインスタンス生成とDB接続、現在日時取得
      def self.init( db_dir , migrate_dir , config_dir , dbconfig, env , log_fname, opts )
        dbinit = Dbinit.new( db_dir, migrate_dir , config_dir , dbconfig, env , log_fname, opts )
        self.setup( dbinit )
      end

      # DB接続、現在日時取得
      def self.setup( dbinit )
        @@ret ||= nil
        unless @@ret
          begin
            dbinit.setup
            @@ret = DateTime.now.new_offset
          rescue => ex
            pp ex.class
            pp ex.message
            pp ex.backtrace
          end
        end

        @@ret
      end
    end
  end
end

