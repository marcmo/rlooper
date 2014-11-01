require 'handler'
require 'message'
require 'looper_thread'
require 'minitest/autorun'
require 'minitest/unit'

module Events
	INVALID_EVENT = 0
	PING          = 8001
	PONG          = 8002
	FINISHED      = 8003
end

class Partner < Looper::Handler
  attr_reader :events
  def initialize()
    @message1 = Looper::Message.new
    @events = []
  end
  def init(_looper, _handler)
    set_looper(_looper)
    @partner = _handler
  end

  def send_event_to(e, n = nil)
    if @partner != nil
      res = Looper::Message::reuse(@message1, @partner, e, n)
      if !res
        puts "could not obtain message from handler"
        return
      end
      res = @partner.send_message(@message1)
			if !res
				puts "could not send message"
      end
    end
  end
  def handle_message(m)
    case m.what
    when Events::PING
				puts "#{name}: received PING from partner"
				received_event(Events::PING)
				n = m.arg1
				if n > 0
          send_event_to(Events::PONG, n - 1)
        else
          send_event_to(Events::FINISHED)
        end
    when Events::PONG
				puts "#{name}: received PONG from partner"
				received_event(Events::PONG)
				send_event_to(Events::PING, m.arg1)
    when Events::FINISHED
				puts "#{name}: received FINISHED"
    end
  end

  def received_event(e)
    @events << e
  end
end
class Pinger < Partner
  def name
    "PINGER"
  end
end
class Ponger < Partner
  def name
    "PONGER"
  end
end

class TestMeme < MiniTest::Unit::TestCase
  def setup
    @looper_thread1 = Looper::LooperThread.new
    @looper_thread2 = Looper::LooperThread.new
    @thread1 = Thread.new { @looper_thread1.run }
    @thread2 = Thread.new { @looper_thread2.run }
  end

  def teardown
    @looper_thread1.get_looper.quit
    @thread1.join
    @looper_thread2.get_looper.quit
    @thread2.join
  end

  def test_send_receive_ping_pong
    pinger = Pinger.new
    ponger = Ponger.new
    pinger.init(@looper_thread1.get_looper(), ponger)
    ponger.init(@looper_thread2.get_looper(), pinger)
    ping_pongs = 5
    pinger.send_event_to(Events::PING, ping_pongs)
    p "PINGER just sent PING"
    sleep(0.1)
    assert_equal(ping_pongs, pinger.events.size())
    assert_equal(Events::PONG, pinger.events.first)
  end

end
