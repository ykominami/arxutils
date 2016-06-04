# -*- coding: utf-8 -*-

module Arxutils
  def load_file( in_file )
    File.open( in_file , "r" , { :encoding => 'UTF-8' } )
  end
  
  def normalize_to_integer( *args )
    args.map{ |x|
      if x != nil and x !~ /^\s*$/
        x.to_i
      else
        nil
      end
    }
  end
      
      def update_integer( model , hs )
        value_hs = hs.reduce({}){ |hsx,item|
          val = model.send(item[0])
          if val == nil or val  < item[1]
            hsx[ item[0] ] = item[1]
          end
          hsx
        }
        if value_hs.size > 0
          begin
            model.update(value_hs)
          rescue => ex
            puts ex.message
          end
        end
      end

end
