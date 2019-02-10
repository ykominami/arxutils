# -*- coding: utf-8 -*-
require 'arxutils'

require 'fileutils'
require 'active_support'
require 'active_record'
require 'pp'

# ActiveRecord用ユーティリティモジュール
module Arxutils
  ##
  # migrateに必要なファイルをテンプレートから作成し、migarteを実行する
  class Migrate
    # migrate用スクリプトファイル名の先頭の番号の間隔
    FILENAME_COUNTER_STEP = 10

    # migrateに必要なファイルをテンプレートから作成し、migarteを実行する
    def self.migrate( db_dir , src_config_dir , log_fname, migrate_dir, env, db_scheme_ary , dbconfig , opts )
      log_file_name = sprintf("%s-%s" , dbconfig.to_s , log_fname )
      mig = Migratex.new( db_dir ,  migrate_dir , src_config_dir , dbconfig, env, log_file_name, opts )
      # DB構成情報の生成
      # dbconfigのテンプレートは内容が固定である。
      if( opts["makeconfig"] )
        mig.make_dbconfig( opts )
        return
      end
      # スキーマ設定配列から、migrate用のスクリプトを作成する
      db_scheme_ary.map{ |x| mig.make_script_group(x) }.flatten(1).each_with_index{|data , index|
        idy = (index + 1) * FILENAME_COUNTER_STEP
        mig.output_script( idy , *data )
      }
      # スキーマ設定配列から、relationのmigrate用のスクリプトの内容(ハッシュ形式)の配列を作成する
      content_array = db_scheme_ary.map { |x|
        mig.make_relation( x , "count" )
      }.select{ |x| x.size > 0 }
      # 複数形のクラス名を集める
      need_count_class_plural = content_array.select{ |x| x[:need_count_class_plural] != nil }.map{ |x| x[:need_count_class_plural] }

      # relationのmigrateが必要であれば、それをテンプレートファイルから作成して、スクリプトの内容として追加する
      if content_array.find{|x| x != nil}
        data_count = {count_classname: "Count" ,
                      need_count_class_plural: need_count_class_plural,
                     }
        ary = content_array.collect{|x| x[:content] }.flatten
        count_content = mig.convert_count_class_relation( data_count , "relation_count.tmpl" )
        ary.unshift( count_content )
        content_array = ary
      end
      # relationのスクリプトを作成
      mig.output_relation_script( content_array , opts[:relation] )

      # データベース接続とログ設定
      ::Arxutils::Dbutil::DbMgr.setup( mig.dbinit )

      # migrateを実行する
      mig.migrate
    end

    # migrate用のスクリプトの内容をテンプレートから作成し、ファイルに出力し、migrateを実行する
    class Migratex
      # DB接続までの初期化を行うDbinitクラスのインスタンス
      attr_reader :dbinit

      # migrate用のスクリプトの生成、migrateの実行を行うmigratexの生成
      def initialize( db_dir , migrate_base_dir , src_config_dir , dbconfig, env, log_fname, opts )
        # DB接続までの初期化を行うDbinitクラスのインスタンス
        @dbinit = Dbutil::Dbinit.new( db_dir , migrate_base_dir , src_config_dir , dbconfig, env, log_fname, opts )
        # 生成するDB構成情報ファイルパス
        @dbconfig_dest_path = @dbinit.dbconfig_dest_path
        # 参照用DB構成情報ファイル名
        @dbconfig_src_fname = @dbinit.dbconfig_src_fname

        # migrate用スクリプトの出力先ディレクトリ名
        @migrate_dir = @dbinit.migrate_dir
        # テンプレートファイル格納ディレクトリ名
        @src_path = Arxutils.templatedir
        # 構成ファイル格納ディレクトリ
        @src_config_path = Arxutils.configdir
      end

      # Countクラス用のrelationのスクリプトの内容に変換
      def convert_count_class_relation( data , src_fname )
        convert( data , @src_path , src_fname )
      end

      # テンプレートファイルからスクリプトの内容に変換
      def convert( data , src_dir , src_fname )
        arx = Arx.new( data , File.join( src_dir, src_fname ) )
        # 指定テンプレートファイルからスクリプトの内容に作成
        arx.create
      end

      # データベース構成ファイルをテンプレートから生成する
      def make_dbconfig( data )
        content = convert( data , @src_config_path , @dbconfig_src_fname )
        File.open( @dbconfig_dest_path , 'w' , {:encoding => Encoding::UTF_8}){ |f|
          f.puts( content )
        }
      end

      # 英子文字で表現したクラス名が、countを表していなければ、relationを
      # 英子文字で表現したクラス名が、countを表していれが、空のハッシュを返す
      # スキーマでbase, noitem以外のフィールドが指定されていれば、そのフィールドに対するrelationの設定の内容を返す
      def make_relation( data , count_classname_downcase )
        if data[:classname_downcase] != count_classname_downcase
          # 指定フィールドのフィールド名に対応したテンプレートファイルを用いて、relation設定を作成
          data[:flist].reduce( { content: [], need_count_class: nil } ){ |s, field_name|
            case field_name
            when "base" , "noitem"
              name_base = "relation"
              # data[:relation]がnilに設定されていたら改めて空の配列を設定
              data[:relation] = [] unless data[:relation]
            else
              data[:count_classname_downcase] = count_classname_downcase
              name_base = "relation_#{field_name}"
              s[:need_count_class_plural] ||= data[:plural]
            end
            # テンプレートファイルからスクリプトの内容を作成
            content = convert( data , @src_path , "#{name_base}.tmpl" )
            s[:content] << content
            s
          }
        else
          {}
        end
      end

      # スキーマ設定からmigarte用スクリプトの内容を生成
      def make_script_group( data )
        data[:flist].map{ |kind| [kind, convert( data , @src_path , "#{kind}.tmpl" ), data[:classname_downcase]]}
      end

      # migrationのスクリプトをファイル出力する
      def output_script( idy, kind , content , classname_downcase )
          case kind
          when "base" , "noitem"
            additional = ""
          else
            additional = kind
          end
          fname = File.join( @migrate_dir , sprintf("%03d_create_%s%s.rb" , idy , additional , classname_downcase) )
          File.open( fname , 'w' , {:encoding => Encoding::UTF_8}){ |f|
            f.puts( content )
          }
      end

      # relationのスクリプトをファイル出力する
      def output_relation_script( content_array , opts )
        dir = opts[:dir]
        fname = opts[:filename]
        fpath = File.join( dir , fname )
        File.open( fpath , "w" ){ |file|
          opts[:module].map{|mod| file.puts("module #{mod}")}
          content_array.map{|x|
            file.puts x
            file.puts ""
          }
          opts[:module].map{|mod| file.puts("end")}
        }
      end

      # migrateを実行する
      def migrate
        ActiveRecord::Migrator.migrate(@migrate_dir ,  ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
      end
    end
  end
end
