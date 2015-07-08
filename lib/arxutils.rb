require "arxutils/version"

module Arxutils
  # Your code goes here...
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

    def Arxutils.sqlite3yaml
      File.join( Arxutils.dirname , 'sqlite3.yaml')
    end
  end
end
