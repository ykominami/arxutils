# -*- coding: utf-8 -*-
require 'erb'

module Arxutils
  class Arx
    attr_accessor :classname , :classname_downcase, :classname_downcase_plural
    
    def initialize( fname )
      @fname = fname

      begin
        @field = Struct::Field
      rescue => exc
        @field = Struct.new("Field" , :name, :type, :null ) 
      end

      init
      @classname_downcase = @classname.downcase
      setPlural
    end

    def get_filepath(fname)
      #    ENV['RUBYLIB']
      $LOAD_PATH.reduce([]) do | ary , path |
        fpath = File.join( path , fname )
        ary << fpath if File.exist?( fpath )
        ary
      end
    end
    
    def create
      filepath = get_filepath( @fname ).first
      contents = File.open( filepath ).read

      erb = ERB.new(contents)
      erb.result(binding)
    end
  end
end


