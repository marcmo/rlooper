require 'thread'
require 'message'

module Looper
  class MessageQueue
    def initialize()
      @head_message = nil
      @lock_message_queue = false
      @mutex = Mutex.new
      @cond_var = ConditionVariable.new
    end

    def enqueue_message(message, exec_timestamp)
      @mutex.synchronize do
        return false if message.exec_timestamp != 0
        return false if @lock_message_queue
        if (message.handler.nil?)
          puts "locking message queue!"
          @lock_message_queue = true
        end
        message.exec_timestamp = exec_timestamp
        cur_message = @head_message
        if (cur_message == nil || exec_timestamp == 0 || exec_timestamp < cur_message.exec_timestamp)
          message.next_message = cur_message
          @head_message = message
          @cond_var.signal
        else
          prev_message = nil
          while (cur_message != nil && cur_message.exec_timestamp <= exec_timestamp)
            prev_message = cur_message
            cur_message = cur_message.next_message
          end
          message.next_message = prev_message.next_message
          prev_message.next_message = message
          @cond_var.signal
        end
        return true
      end
    end

    def dequeue_message()
      while true do
        @mutex.synchronize do
          now = Time.now.nsec
          m = get_next_message(now)
          if m != nil
            m.exec_timestamp = 0
            return m
          end
          if @head_message != nil
            next_message_timeout = @head_message.exec_timestamp - now
            if next_message_timeout > 0
              @cond_var.wait(@mutex, 0.001 * 0.001 * 0.001 * next_message_timeout)
            end
          else
            @cond_var.wait(@mutex)
          end
        end
      end
    end

    def get_next_message(now_ns)
      m = @head_message
      if (m != nil)
        if now_ns >= m.exec_timestamp
          @head_message = m.next_message
          return m
        end
      end
      return nil
    end

  # TODO remove_messages

  end
end
# bool MessageQueue::removeMessages(const sp<Handler>& handler, int32_t what) {
# 	if (handler == NULL) {
# 		return false;
# 	}
#
# 	bool foundMessage = false;
#
# 	mCondVarLock.lock();
#
# 	sp<Message> curMessage = mHeadMessage;
# 	// remove all matching messages at the front of the message queue.
# 	while (curMessage != NULL && curMessage->mHandler == handler && curMessage->what == what) {
# 		foundMessage = true;
# 		sp<Message> nextMessage = curMessage->mNextMessage;
# 		mHeadMessage = nextMessage;
# 		curMessage = nextMessage;
# 	}
#
# 	// remove all matching messages after the front of the message queue.
# 	while (curMessage != NULL) {
# 		sp<Message> nextMessage = curMessage->mNextMessage;
# 		if (nextMessage != NULL) {
# 			if (nextMessage->mHandler == handler && nextMessage->what == what) {
# 				foundMessage = true;
# 				sp<Message> nextButOneMessage = nextMessage->mNextMessage;
# 				nextMessage = NULL;
# 				curMessage->mNextMessage = nextButOneMessage;
# 				continue;
# 			}
# 		}
# 		curMessage = nextMessage;
# 	}
#
# 	mCondVarLock.unlock();
#
# 	return foundMessage;
# }
#
# bool MessageQueue::removeCallbacks(const sp<Handler>& handler, const sp<Runnable>& runnable) {
# 	if (handler == NULL || runnable == NULL) {
# 		return false;
# 	}
#
# 	bool foundRunnable = false;
#
# 	mCondVarLock.lock();
#
# 	sp<Message> curMessage = mHeadMessage;
# 	// remove all matching messages at the front of the message queue.
# 	while (curMessage != NULL && curMessage->mHandler == handler && curMessage->mCallback == runnable) {
# 		foundRunnable = true;
# 		sp<Message> nextMessage = curMessage->mNextMessage;
# 		mHeadMessage = nextMessage;
# 		curMessage = nextMessage;
# 	}
#
# 	// remove all matching messages after the front of the message queue.
# 	while (curMessage != NULL) {
# 		sp<Message> nextMessage = curMessage->mNextMessage;
# 		if (nextMessage != NULL) {
# 			if (nextMessage->mHandler == handler && nextMessage->mCallback == runnable) {
# 				foundRunnable = true;
# 				sp<Message> nextButOneMessage = nextMessage->mNextMessage;
# 				nextMessage = NULL;
# 				curMessage->mNextMessage = nextButOneMessage;
# 				continue;
# 			}
# 		}
# 		curMessage = nextMessage;
# 	}
#
# 	mCondVarLock.unlock();
#
# 	return foundRunnable;
# }
#
# bool MessageQueue::removeCallbacksAndMessages(const sp<Handler>& handler) {
# 	if (handler == NULL) {
# 		return false;
# 	}
#
# 	bool foundSomething = false;
#
# 	mCondVarLock.lock();
#
# 	sp<Message> curMessage = mHeadMessage;
# 	// remove all matching messages at the front of the message queue.
# 	while (curMessage != NULL && curMessage->mHandler == handler) {
# 		foundSomething = true;
# 		sp<Message> nextMessage = curMessage->mNextMessage;
# 		mHeadMessage = nextMessage;
# 		curMessage = nextMessage;
# 	}
#
# 	// remove all matching messages after the front of the message queue.
# 	while (curMessage != NULL) {
# 		sp<Message> nextMessage = curMessage->mNextMessage;
# 		if (nextMessage != NULL) {
# 			if (nextMessage->mHandler == handler) {
# 				foundSomething = true;
# 				sp<Message> nextButOneMessage = nextMessage->mNextMessage;
# 				nextMessage = NULL;
# 				curMessage->mNextMessage = nextButOneMessage;
# 				continue;
# 			}
# 		}
# 		curMessage = nextMessage;
# 	}
#
# 	mCondVarLock.unlock();
#
# 	return foundSomething;
# }
#
# } /* namespace mindroid */
