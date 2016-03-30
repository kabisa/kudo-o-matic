class DashboardController < ApplicationController
  def index
    @previous = Goal.previous.decorate
    @next     = Goal.next.decorate

    @balance  = Balance.current.decorate
  end
end
