# -*- coding: utf-8 -*-
require 'arxutils'

require 'fileutils'
require 'active_support'
require 'active_record'
require 'pp'

module Arxutils
  class Migrate
    attr_accessor :dbinit , :dbconfig_dest_path , :dbconfig_dest_fname , :dbconfig_src_path , :dbconfig_src_fname
    
#    def Migrate.migrate( data_ary , relation_def_fpath , module_name, count_classname_downcase , dbconfig , forced )
    def Migrate.migrate( db_dir , src_config_dir , log_fname, migrate_dir, env, data_ary , dbconfig , forced )
      src_config_dir = Arxutils.configdir
      log_file_name = sprintf("%s-%s" , dbconfig.to_s , log_fname )
      mig = Migrate.new( db_dir ,  migrate_dir , src_config_dir , dbconfig, env, log_file_name, forced )
      # dbconfigのテンプレートは内容が固定である。convertを呼び出し、Arxのインスタンスを作成するときに、適切なdata_aryの要素を与える必要がある（ただしテンプレートへの埋め込みには用いられない
#      mig.make_dbconfig( data_ary )
      data_ary.map{ |x| mig.make_dbconfig( x ) }
      
      data_ary.reduce(0) { |next_num , x| 
        mig.make( next_num , x )
      }

      content_array = data_ary.map { |x| 
        mig.make_relation( x , "count" )
      }.select{ |x| x.size > 0 }
      need_count_class_plural = content_array.reduce([]){ |s,x|
        s << x[:need_count_class_plural] if x[:need_count_class_plural] != nil
        s
      }
      if content_array.size > 0
        data_count = {count_classname: "Count" ,
                      need_count_class_plural: need_count_class_plural,
                     }
        ary = content_array.collect{|x| x[:content] }.flatten
        count_content = mig.convert_count_class_relation( data_count , "relation_count.tmpl" )
        ary.unshift( count_content )
        content_array = ary
      end
=begin      
      File.open( relation_def_fpath , 'w' , {:encoding => Encoding::UTF_8}){ |f|
        f.puts("module #{module_name}")
        content_array.map{ |content|
          f.puts( content )
          f.puts( "\n" )
        }
        f.puts("end")
      }
=end      
      Dbutil::DbMgr.setup( mig.dbinit )

      mig.migrate
    end
    
    def initialize( db_dir , migrate_base_dir , src_config_dir , dbconfig, env, log_fname, forced )
      @dbinit = Dbutil::Dbinit.new( db_dir , migrate_base_dir , src_config_dir , dbconfig, env, log_fname, forced )
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

    def migrate
      ActiveRecord::Migrator.migrate(@migrate_dir ,  ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
    end
  end
end
