# -*- coding: utf-8 -*-

module Arxutils
  class Arxutils
    def Arxutils.dirname
      File.dirname( __FILE__ )
    end

    def Arxutils.templatedir
      File.join( Arxutils.dirname , "template" )
    end

    def Arxutils.rakefile
      File.join( Arxutils.dirname , 'Rakefile')
    end

    def Arxutils.configdir
      File.join( Arxutils.dirname , 'config' )
    end
  end
end
