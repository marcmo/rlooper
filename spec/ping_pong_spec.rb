require 'handler'
require 'message'
require 'looper_thread'
require 'minitest/autorun'
require 'minitest/unit'

module Events
	INVALID_EVENT = 0
	PING = 8001
	PONG = 8002
end

class Partner < Looper::Handler
  attr_reader :events
  def initialize()
    @message1 = Looper::Message.new
    @events = []
  end
  def init(_looper, _handler)
    p "in partner init"
    set_looper(_looper)
    @partner = _handler
  end

  def send_event_to(e)
    if @partner != nil
      res = Looper::Message::obtain_with_message_and_what(@message1, @partner, e)
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
				puts "received PING from partner, sending back PONG"
				received_event(Events::PING)
				send_event_to(Events::PONG)
    when Events::PONG
				puts "#{name}: received PONG from partner"
				received_event(Events::PONG)
    end
  end

  def received_event(e)
    puts "#{name}: received event #{e}"
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
    puts "setup (#{Thread.current})"
    @looper_thread1 = Looper::LooperThread.new
    @looper_thread2 = Looper::LooperThread.new
    @thread1 = Thread.new { @looper_thread1.run }
    @thread2 = Thread.new { @looper_thread2.run }
  end

  def teardown
    puts 'teardown'
    @looper_thread1.get_looper.quit
    @thread1.join
    @looper_thread2.get_looper.quit
    @thread2.join
  end

  def test_send_receive_ping_pong
    p "test_send_receive_ping_pong"
    pinger = Pinger.new
    ponger = Ponger.new
    p "got pinger and ponger"
    pinger.init(@looper_thread1.get_looper(), ponger)
    p "pinger inited"
    ponger.init(@looper_thread2.get_looper(), pinger)
    p "ponger inited"
    pinger.send_event_to(Events::PING)
    p "sent PING"
    sleep(1.0)
    count = 1
    assert_equal(1, pinger.events.size())
    assert_equal(Events::PONG, pinger.events.first)
  end

end
#
# TEST_F(MindroidPingPongTest, sendReceivePingPong)
# {
# 	Pinger pinger;
# 	Ponger ponger;
# 	pinger.init(*fpHandlerThread1->getLooper(), ponger);
# 	ponger.init(*fpHandlerThread2->getLooper(), pinger);
#
# 	pinger.sendEventTo(PING);
# 	usleep(1000);
#
#     uint32_t count = 1;
# 	ASSERT_EQ(count, pinger.getEvents().size());
# 	ASSERT_EQ(PONG, pinger.getEvents().front());
# 	pinger.getEvents().pop_front();
#
# 	ASSERT_EQ(count, ponger.getEvents().size());
# 	ASSERT_EQ(PING, ponger.getEvents().front());
# 	ponger.getEvents().pop_front();
# }
#
#
