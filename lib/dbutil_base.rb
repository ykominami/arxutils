# -*- coding: utf-8 -*-
require 'date'
require 'active_record'
require 'sqlite3'
require 'encx/encx'
require 'dbinit'
require 'pp'

module Arxutils
  module Dbutil
    class DbMgr
      def DbMgr.init(config_path = 'config/sqlite3.yaml' , log_fname =  'db/database.log' )
        @@ret ||= nil
        unless @@ret
          begin
            Dbinit.init( config_path , log_fname )
            @@ret = DateTime.now.new_offset
          rescue => ex
            p ex.class
            p ex.message
            pp ex.backtrace
          end
        end

        @@ret
      end

      def DbMgr.conv_string(value , encoding)
        if value.class == String
          if value.encoding != encoding
            value.encode(encoding)
          else
            value
          end
        else
          value
        end
      end
      
      def DbMgr.conv_boolean( k , v )
        ret = v
        if k =~ /enable/
          if v.class == String
            case v
            when 'T'
              ret = true
            when 'F'
              ret = false
            else
              raise
            end
          elsif v.class == TrueClass
            # do nothin
          elsif v.class == FalseClass
            # do nothin
          else
            p v.class
            p v
            raise
          end
        end
        ret
      end
    end
  end
end
