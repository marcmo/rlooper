require 'thread'
require 'message'
require 'message_queue'

module Looper
  class Looper

    attr_reader :queue

    def initialize
      @queue = MessageQueue.new
    end

    def self.prepare
      _looper = Thread.current[:looper]
      if (_looper == nil)
        _looper = Looper.new
        Thread.current[:looper] = _looper
      end
    end

    def self.my_looper
      Thread.current[:looper]
    end

    def self.loop
      me = my_looper
      if (me != nil)
        q = me.queue
        while (true) do
          m = q.dequeue_message
          puts "picked up #{m.id} message from queue"
          return if (m.handler.nil?)
          m.handler.dispatch_message(m)
        end
      end
    end

    def quit
      m = Message.obtain()
      puts "in Looper::quit: enqueue quit message #{m}"
      @queue.enqueue_message(m, 0)
    end
  end
end






