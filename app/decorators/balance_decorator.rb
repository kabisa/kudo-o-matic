class BalanceDecorator < Draper::Decorator
  delegate_all

  def kudos
    h.number_to_kudos(object.amount)
  end
end
