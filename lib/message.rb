require 'thread'

module Looper

  class Message
    MAX_POOL_SIZE = 10
    attr_reader :what, :arg1, :arg2, :obj
    attr_accessor :handler, :exec_timestamp, :next_message, :id
    @@pool_size = 0
    @@pool_mutex = Mutex.new
    @@pool = nil
    @@pool_size = 0

    def initialize(handler = nil, what = nil, arg1 = nil, arg2 = nil)
      @handler = handler
      @what = what
      @arg1 = arg1
      @arg2 = arg2
      @exec_timestamp = 0
    end

    def reset!(handler = nil, what = nil, arg1 = nil, arg2 = nil)
      initialize(handler, what, arg1, arg2)
    end

    def self.obtain()
      @@pool_mutex.synchronize do
        if @pool != nil
          m = @@pool
          @@pool = m.next
          m.next = nil
          @@message_pool_size -= 1
          return n
        end
      end
      Message.new
    end

    def self.reuse(message, handler, what = nil, arg1 = nil, arg2 = nil)
      return false unless (0 == message.exec_timestamp)
      message.reset!(handler, what, arg1, arg2)
      true
    end

    # Return a Message instance to the global pool.  You MUST NOT touch
    # the Message after calling this function -- it has effectively been
    # freed.
    def recycle()
      @@pool_mutex.synchronize do
          if (@@pool_size < MAX_POOL_SIZE)
              clear_for_recycle()
              @next = @@pool;
              @@pool = this
              @@message_pool_size += 1
          end
      end
    end

    def clear_for_recycle()
        @what = 0
        @arg1 = 0
        @arg2 = 0
        @obj = nil
        @reply_to = nil
        @when = 0
        @target = nil
        @data = nil
    end

    private :recycle, :clear_for_recycle
  end
end

