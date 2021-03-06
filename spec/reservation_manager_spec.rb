require_relative "spec_helper"

describe "ReservationManager" do
  let(:manager_new) do
    Hotel::ReservationManager.new
  end

  let(:reservation_generator) do
    # Reservation 1
    start_date = Time.parse("2019-03-11 14:08:45 -0700")
    end_date = Time.parse("2019-03-15 14:08:45 -0700")
    room = 3
    manager_new.create_reservation(start_date, end_date, room)
    # Reservation 2
    start_date = Time.parse("2019-03-20 14:08:45 -0700")
    end_date = Time.parse("2019-03-22 14:08:45 -0700")
    room = 20
    manager_new.create_reservation(start_date, end_date, room)
    # Reservation 3
    start_date = Time.parse("2019-02-27 14:08:45 -0700")
    end_date = Time.parse("2019-02-28 14:08:45 -0700")
    room = 12
    manager_new.create_reservation(start_date, end_date, room)
    # Reservation 4
    start_date = Time.parse("2019-03-19 14:08:45 -0700")
    end_date = Time.parse("2019-03-21 14:08:45 -0700")
    room = 6
    manager_new.create_reservation(start_date, end_date, room)
  end

  let (:block_generator) do
    # Block 1
    start_date = Time.parse("2019-03-12 14:08:45 -0700")
    end_date = Time.parse("2019-03-17 14:08:45 -0700")
    room = [1, 4, 5, 6, 8]
    discount = 0.25
    block_id = "puppies convention"
    manager_new.create_block(start_date, end_date, room, block_id: block_id, discount: discount)
  end

  describe "create reservation" do
    it "creates a reservation" do
      expect(reservation_generator).must_be_instance_of Hotel::Reservation
    end

    it "raises ArgumentError when date range is invalid" do
      id = 1
      start_time = Time.parse("2019-03-19 14:08:45 -0700")
      end_time = Time.parse("2019-03-15 14:08:45 -0700")
      room_number = 3

      expect { Hotel::ReservationManager.new(start_time, end_time, room_number) }.must_raise ArgumentError
    end

    it "creates a reservation for an available room" do
      reservation_generator
      reservation = manager_new.create_reservation(Time.parse("2019-03-21 14:08:45 -0700"), Time.parse("2019-03-26 14:08:45 -0700"), 6)
      expect(reservation).must_be_instance_of Hotel::Reservation
    end

    it "raises ArgumentError when a room chosen is not existent" do
      expect { manager_new.create_reservation(Time.parse("2019-03-21 14:08:45 -0700"), Time.parse("2019-03-26 14:08:45 -0700"), 24) }.must_raise ArgumentError
    end

    it "raises ArgumentError when a room chosen is not available" do
      reservation_generator

      expect { manager_new.create_reservation(Time.parse("2019-03-19 14:08:45 -0700"), Time.parse("2019-03-26 14:08:45 -0700"), 6) }.must_raise ArgumentError
    end

    it "raises ArgumentError when range of dates are invalid" do
      start_date = Time.parse("2019-03-19 14:08:45 -0700")
      end_date = Time.parse("2019-03-17 14:08:45 -0700")
      room = 4
      expect { manager_new.create_reservation(start_date, end_date, room) }.must_raise ArgumentError
    end

    it "Creates a reservation when it starts on the same day another ends" do
      reservation_generator
      start_date = Time.parse("2019-03-22 14:08:45 -0700")
      end_date = Time.parse("2019-03-24 14:08:45 -0700")
      room = 20
      expect(manager_new.create_reservation(start_date, end_date, room)).must_be_instance_of Hotel::Reservation
    end
  end

  describe "rooms" do
    it "shows the list of rooms in the hotel" do
      expect(manager_new.rooms).must_be_kind_of Array
    end
  end

  describe "store reservations" do
    it "stores the reservations" do
      reservation_generator

      expect(manager_new.reservations).must_be_kind_of Array
      expect(manager_new.reservations.length).must_equal 4
    end
  end

  describe "find by id" do
    it "finds a reservation by id" do
      reservation_generator

      expect(manager_new.find_by_id(id: 1).start_date).must_equal Time.parse("2019-03-11 14:08:45 -0700")
      expect(manager_new.find_by_id(id: 2)).must_be_kind_of Hotel::Reservation
      expect(manager_new.find_by_id(id: 3).start_date).must_equal Time.parse("2019-02-27 14:08:45 -0700")
      expect(manager_new.find_by_id(id: 4)).must_be_kind_of Hotel::Reservation
    end

    it "raises ArgumentError when the id is not valid" do
      reservation_generator

      expect { manager_new.find_by_id(id: 8) }.must_raise ArgumentError
    end

    it "returns the total cost per reservation" do
      reservation_generator

      expect(manager_new.find_by_id(id: 1).total_cost).must_equal 800
      expect(manager_new.find_by_id(id: 3).total_cost).must_equal 200
      expect(manager_new.find_by_id(id: 2).total_cost).must_equal 400
      expect(manager_new.find_by_id(id: 4).total_cost).must_equal 400
      # This test makes more sense on reservation rather than the manager.
    end
  end

  describe "find by date" do
    it "finds reservations by date" do
      reservation_generator

      expect(manager_new.find_by_date(Time.parse("2019-03-19 14:08:45 -0700"), Time.parse("2019-03-22 14:08:45 -0700"))).must_be_kind_of Array
      expect(manager_new.find_by_date(Time.parse("2019-02-27 14:08:45 -0700"), Time.parse("2019-02-28 14:08:45 -0700"))).must_be_kind_of Array
    end

    it "raises ArgumentError when there are no reservations for date range" do
      reservation_generator

      expect { manager_new.find_by_date(Time.parse("2019-01-01 14:08:45 -0700"), Time.parse("2019-01-20 14:08:45 -0700")) }.must_raise ArgumentError
      expect { manager_new.find_by_date(Time.parse("2020-01-27 14:08:45 -0700"), Time.parse("2020-01-28 14:08:45 -0700")) }.must_raise ArgumentError
      #I would suggest that this method should simply return an empty array when no reservation falls in the date range.
    end
  end
  describe "find available rooms" do
    it "finds available rooms" do
      reservation_generator

      expect(manager_new.find_available_rooms(Time.parse("2019-03-18 14:08:45 -0700"), Time.parse("2019-03-22 14:08:45 -0700"))).must_be_kind_of Array
      expect { manager_new.find_available_rooms(Time.parse("2019-01-24 14:08:45 -0700"), Time.parse("2019-01-27 14:08:45 -0700")) }.must_raise ArgumentError
      #The second expect, looks like it's testing for a separate test.
    end
  end

  describe "create blocks" do
    it "creates a block" do
      start_date = Time.parse("2019-03-12 14:08:45 -0700")
      end_date = Time.parse("2019-03-17 14:08:45 -0700")
      room = [1, 4, 5, 6, 8]
      discount = 0.05
      block_id = "puppies convention"
      expect(manager_new.create_block(start_date, end_date, room, block_id: block_id, discount: discount)).must_equal true
    end

    it "raises argument error when there are more than 5 rooms in the block" do
      start_date = Time.parse("2019-03-12 14:08:45 -0700")
      end_date = Time.parse("2019-03-17 14:08:45 -0700")
      room = [1, 4, 5, 6, 8, 12]
      discount = 0.05
      block_id = "puppies convention"
      expect { manager_new.create_block(start_date, end_date, room, block_id: block_id, discount: discount) }.must_raise ArgumentError
    end
  end

  describe "reserve from block" do
    it "reserves from block" do
      reservation_generator
      block_generator
      id = "puppies convention"
      expect(manager_new.reserve_from_block(id)).must_be_kind_of Integer
    end

    it "calculates the total price with discount for block" do
      reservation_generator
      block_generator
      id = "puppies convention"
      manager_new.reserve_from_block(id)
      expect(manager_new.find_by_id(id: 5).total_cost).must_equal 750
    end

    it "raises argument error when any of the rooms in the block is in another block" do
      block_generator

      start_date = Time.parse("2019-03-12 14:08:45 -0700")
      end_date = Time.parse("2019-03-17 14:08:45 -0700")
      room = [11, 14, 15, 6, 8]
      discount = 0.50
      block_id = "whales of the land"
      expect { manager_new.create_block(start_date, end_date, room, block_id: block_id, discount: discount) }.must_raise ArgumentError
    end

    it "raises argument error when any of the rooms in the block is already reserved" do
      reservation_generator

      start_date = Time.parse("2019-03-12 14:08:45 -0700")
      end_date = Time.parse("2019-03-17 14:08:45 -0700")
      room = [11, 14, 15, 3, 20]
      discount = 0.50
      block_id = "whales of the land"
      expect { manager_new.create_block(start_date, end_date, room, block_id: block_id, discount: discount) }.must_raise ArgumentError
    end

    it "raises argument error when there are not rooms available in the block" do
      block_generator
      id = "puppies convention"
      5.times do
        manager_new.reserve_from_block(id)
      end
      expect { manager_new.reserve_from_block(id) }.must_raise ArgumentError
    end
  end
end
