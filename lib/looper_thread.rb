require 'looper'
require 'thread'


module Looper
  class LooperThread

    def initialize()
      @mutex = Mutex.new
      @cond_var = ConditionVariable.new
      @is_done = false
    end

    def run
      p "run(#{Thread.current})"
      Looper::prepare()
      puts "looper is prepared in thread #{Thread.current}"
      @mutex.synchronize do
        @looper = Looper::my_looper()
        @handler = Handler.new
        p "broadcast(#{Thread.current})"
        @cond_var.broadcast()
      end
      Looper::loop
      @mutex.synchronize do
        @is_done = true
        # @handler.removeCallbacksAndMessages
        @looper = nil
        @handler = nil
      end
    end

    def get_looper
      @mutex.synchronize do
        if (!@is_done && @looper == nil)
          if @looper.nil? then p "looper was nil, waiting (#{Thread.current})" end
          @cond_var.wait(@mutex)
          p "done waiting(#{Thread.current})"
        end
      end
      @looper
    end

    def get_handler()
      @mutex.synchronize do
        if (!@is_done && @handler == nil)
          @cond_var.wait(@mutex)
        end
      end
    end
  end
end
