# -*- coding: utf-8 -*-
require 'erb'

module Arxutils
  class Arx
#    attr_accessor :classname , :classname_downcase, :classname_downcase_plural
    
    def initialize( data , fname )
      @fname = fname
      @data = data

      begin
        @field = Struct::Field
      rescue => exc
        @field = Struct.new("Field" , :name, :type, :null ) 
      end

      @data[:ary] = @data[:items].map{ |x| @field.new( *x ) }
    end

    def create
#      filepath = get_filepath( @fname ).first
#      contents = File.open( filepath ).read
      contents = File.open( @fname ).read

      erb = ERB.new(contents)
      erb.result(binding)
    end
  end
end


