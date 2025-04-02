class PaymentChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'payment_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def select(data)
  puts data.inspect
  end
end
