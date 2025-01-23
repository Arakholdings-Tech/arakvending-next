class Payments::Queued < Event
  attr_accessor :payment

  def initialize(payment)
    self.payment = payment
  end

  def payload
    super.merge(payment: payment)
  end
end
