# -*- coding: utf-8 -*-
require 'arxutils'

require 'fileutils'
require 'active_support'
require 'active_record'
require 'pp'

module Arxutils
  class Migrate
    # クラスメソッドと、内部クラスで書き換え可能
    def Migrate.migrate( db_dir , src_config_dir , log_fname, migrate_dir, env, db_scheme_ary , dbconfig , opts )
      # src_config_dir = Arxutils.configdir
      log_file_name = sprintf("%s-%s" , dbconfig.to_s , log_fname )
      mig = Migratex.new( db_dir ,  migrate_dir , src_config_dir , dbconfig, env, log_file_name, opts )
      # dbconfigのテンプレートは内容が固定である。
      if( opts["makeconfig"] )
        mig.make_dbconfig( opts )
        return
      end
      # migrate用のスクリプトを作成する
      db_scheme_ary.map{ |x| mig.make_script_group(x) }.flatten(1).each_with_index{|data , index|
        idy = (index + 1) * 10
        mig.output_script( idy , *data )
      }
=begin
      db_scheme_ary.each_with_index { |x , index|
        num = index * 10
        mig.make( num , x )
      }
=end
      # relationのmigrate用のスクリプトを作成する
      content_array = db_scheme_ary.map { |x|
        mig.make_relation( x , "count" )
      }.select{ |x| x.size > 0 }
      # TODO:  enumrableのcollectとmspメソッドの組み合わせで書き換え可能
      need_count_class_plural = content_array.reduce([]){ |s,x|
        s << x[:need_count_class_plural] if x[:need_count_class_plural] != nil
        s
      }
      if content_array.find{|x| x != nil}
#      if content_array.size > 0
        data_count = {count_classname: "Count" ,
                      need_count_class_plural: need_count_class_plural,
                     }
        ary = content_array.collect{|x| x[:content] }.flatten
        count_content = mig.convert_count_class_relation( data_count , "relation_count.tmpl" )
        ary.unshift( count_content )
        content_array = ary
      end
#      ::Arxutils::Dbutil::DbMgr.init( db_dir , migrate_dir , src_config_dir , dbconfig, env , log_fname, opts )
      ::Arxutils::Dbutil::DbMgr.setup( mig.dbinit )

      mig.migrate
    end

    class Migratex
      attr_reader :dbinit
 #     attr_reader :dbconfig_dest_path , :dbconfig_dest_fname , :dbconfig_src_path , :dbconfig_src_fname

      def initialize( db_dir , migrate_base_dir , src_config_dir , dbconfig, env, log_fname, opts )
        @dbinit = Dbutil::Dbinit.new( db_dir , migrate_base_dir , src_config_dir , dbconfig, env, log_fname, opts )
        @dbconfig_dest_path = @dbinit.dbconfig_dest_path
        @dbconfig_src_path = @dbinit.dbconfig_src_path
        @dbconfig_src_fname = @dbinit.dbconfig_src_fname

        @migrate_dir = @dbinit.migrate_dir
        @src_path = Arxutils.templatedir
        @src_config_path = Arxutils.configdir
      end

      def convert_count_class_relation( data , src_fname )
        convert( data , @src_path , src_fname )
      end

      def convert( data , src_dir , src_fname )
        arx = Arx.new( data , File.join( src_dir, src_fname ) )
        arx.create
      end

      # データベース構成ファイルをテンプレートから生成する
      def make_dbconfig( data )
        content = convert( data , @src_config_path , @dbconfig_src_fname )
        File.open( @dbconfig_dest_path , 'w' , {:encoding => Encoding::UTF_8}){ |f|
          f.puts( content )
        }
      end

      def make_relation( data , count_classname_downcase )
        if data[:classname_downcase] != count_classname_downcase
          data[:flist].reduce( { content: [], need_count_class: nil } ){ |s, x|
            case x
            when "base" , "noitem"
              name_base = "relation"
              data[:relation] = [] unless data[:relation]
            else
              data[:count_classname_downcase] = count_classname_downcase
              name_base = "relation_#{x}"
              s[:need_count_class_plural] ||= data[:plural]
            end
            content = convert( data , @src_path , "#{name_base}.tmpl" )
            s[:content] << content
            s
          }
        else
          {}
        end
      end

      def make_script_group( data )
        data[:flist].map{ |kind| [kind, convert( data , @src_path , "#{kind}.tmpl" ), data[:classname_downcase]]}
      end

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
=begin
      def make( next_num , data )
        data[:flist].reduce(next_num) do |idy , x|
          idy += 10
          content = convert( data , @src_path , "#{x}.tmpl" )
          case x
          when "base" , "noitem"
            additional = ""
          else
            additional = x
          end
          fname = File.join( @migrate_dir , sprintf("%03d_create_%s%s.rb" , idy , additional , data[:classname_downcase]) )
          File.open( fname , 'w' , {:encoding => Encoding::UTF_8}){ |f|
            f.puts( content )
          }
          idy
        end
      end
=end
      def migrate
        ActiveRecord::Migrator.migrate(@migrate_dir ,  ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
      end
    end
  end
end
