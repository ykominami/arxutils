module Arxutils
  class TransactState
    attr_accessor :ids , :state
    
    def initialize
      @ids = []
      @state = :NONE
    end

    def add( xid )
      @ids << xid if @state == :TRACE
    end

    def clear
      @ids = []
    end

    def need?
      @ids.size > 0
    end

  end

  class TransactStateGroup
    def initialize( *names )
      @state = :NONE
      @inst = {}
      names.map{|x| @inst[x] = TransactState.new }
    end
    
    def need?
      @state != :NONE
    end
    
    def set_all_inst_state
      @inst.map{|x| x[1].state = @state }
    end
    
    def trace
      @state = :TRACE
      set_all_inst_state
    end
    
    def reset
      @state = :NONE
      set_all_inst_state
    end
    
    def method_missing(name , lang = nil)
      @inst[name] 
    end
  end
end
