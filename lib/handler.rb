require 'looper'
require 'message'

module Looper
  class Handler
    def initialize_empty
      p "handler initialize_empty"
      _looper = Looper::my_looper()
      raise "looper should exist" if _looper.nil?
      @message_queue = _looper.queue
    end

    def initialize_with_looper(_looper)
      p "handler initialize_with_looper"
      @message_queue = _looper.queue
    end

    def dispatch_message(message)
      handle_message(message)
    end

    def handle_message
    end

    def set_looper(_looper)
      @message_queue = _looper.queue
    end

    def send_message(m)
      send_message_at_time(m, Time.now.nsec)
    end

    def send_message_delayed(m, delay)
      send_message_at_time(m, Time.now.nsec + delay * 1000000)
    end

    def send_message_at_time(m, exec_timestamp)
      m.handler = self
      @message_queue.enqueue_message(m, exec_timestamp)
    end

    # TODO
    # def remove_messages(what)
    #   @message_queue.remove_messages(self, what)
    # end

  end
end
#
# bool Handler::post(const sp<Runnable>& runnable) {
# 	if (runnable != NULL) {
# 		const sp<Message>& message = getPostMessage(runnable);
# 		return sendMessage(message);
# 	} else {
# 		return false;
# 	}
# }
#
# bool Handler::postDelayed(const sp<Runnable>& runnable, uint32_t delay) {
# 	if (runnable != NULL) {
# 		const sp<Message>& message = getPostMessage(runnable);
# 		return sendMessageDelayed(message, delay);
# 	} else {
# 		return false;
# 	}
# }
#
# bool Handler::postAtTime(const sp<Runnable>& runnable, uint64_t exec_timestamp) {
# 	if (runnable != NULL) {
# 		const sp<Message>& message = getPostMessage(runnable);
# 		return sendMessageAtTime(message, exec_timestamp);
# 	} else {
# 		return false;
# 	}
# }
#
# sp<Message> Handler::getPostMessage(const sp<Runnable>& runnable) {
# 	const sp<Message> message = Message::obtain();
# 	message->mCallback = runnable;
# 	return message;
# }
#
# bool Handler::removeCallbacks(const sp<Runnable>& runnable) {
# 	return mMessageQueue->removeCallbacks(this, runnable);
# }
#
# bool Handler::removeCallbacksAndMessages() {
# 	return mMessageQueue->removeCallbacksAndMessages(this);
# }
#
