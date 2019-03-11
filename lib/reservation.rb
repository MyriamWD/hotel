
module Hotel
  class Reservation
    attr_reader :start_date, :end_date, :room_number #:total_cost, :nights_amount

    def initialize(start_date, end_date, room_number)
      @start_date = start_date
      @end_date = end_date
      @room_number = room_number
      @total_nights = total_nights
      @total_cost = total_cost
    end

    def total_nights
      total_nights = (end_date - start_date) / 86400
      return total_nights.to_i
    end

    def total_cost
      cost_per_night = 200.0
      total_cost = 0
      total_cost = total_nights * cost_per_night
      return total_cost
    end
  end
end