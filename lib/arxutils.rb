require "arxutils/version"

module Arxutils
  # Your code goes here...
  class Arxutils
    def Arxutils.dirname
      File.dirname( __FILE__ )
    end

    def Arxutils.rakefile
      File.join(@@dirname , 'Rakefile')
    end
  end
end
