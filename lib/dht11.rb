require "rpi_gpio"

require "dht11/version"
require "dht11/result"

module DHT11
  module Level
    HIGH = true
    LOW = false
  end

  module State
    INITIAL_PULL_DOWN = :initial_pull_down
    INITIAL_PULL_UP = :initial_pull_up
    DATA_FIRST_PULL_DOWN = :data_first_pull_down
    DATA_PULL_UP = :data_pull_up
    DATA_PULL_DOWN = :data_pull_down
  end

  class Sensor
    def initialize(pin, tries: 10, interval: 0.1)
      @pin = pin
      @tries = tries
      @interval = interval
      RPi::GPIO.set_numbering(:bcm)
    end

    def read
      @tries.times do 
        @last_result = read_once
        return @last_result if @last_result.valid?
        sleep @interval
      end
      @last_result
    end

    def read_once
      send_initial_signal
      raw_inputs = collect_raw_input
      periods = parse_inputs_into_pull_up_periods(raw_inputs)
      if periods.length != 40
        return Result.new(Err::MISSING_DATA, Float::NAN, Float::NAN)
      end
      bits = calculate_bits(periods)
      bytes = bits_to_bytes(bits)
      checksum = calculate_checksum(bytes)
      if bytes[4] != checksum
        return Result.new(Err::CRC, Float::NAN, Float::NAN)
      end

      temperature = bytes_to_temperature(bytes).to_f
      humidity = bytes_to_humidity(bytes).to_f
      Result.new(Err::NO_ERROR, temperature, humidity)
    end

    private

    def send_and_sleep(output, sleep_second)
      if output == Level::HIGH
        RPi::GPIO.set_high(@pin)
      else
        RPi::GPIO.set_low(@pin)
      end
      sleep sleep_second
    end

    def send_initial_signal
      RPi::GPIO.setup(@pin, as: :output)
      send_and_sleep(Level::HIGH, 0.05)
      send_and_sleep(Level::LOW, 0.02)
    end

    def collect_raw_input
      RPi::GPIO.setup(@pin, as: :input, pull: :up)
      max_unchanged_count = 100
      unchanged_count = 0
      last_input = -1
      raw_inputs = []

      while unchanged_count < max_unchanged_count
        current_input = RPi::GPIO.high?(@pin)
        raw_inputs.push(current_input)
        if last_input == current_input
          unchanged_count += 1
        else
          unchanged_count = 0
          last_input = current_input
        end
      end
      raw_inputs
    end

    def parse_inputs_into_pull_up_periods(raw_inputs)
      state = State::INITIAL_PULL_DOWN
      periods = []
      period = 0

      raw_inputs.each do |input|
        period += 1
        case state
        when State::INITIAL_PULL_DOWN
          if input == Level::LOW
            state = State::INITIAL_PULL_UP
          end
        when State::INITIAL_PULL_UP
          if input == Level::HIGH
            state = State::DATA_FIRST_PULL_DOWN
          end
        when State::DATA_FIRST_PULL_DOWN
          if input == Level::LOW
            state = State::DATA_PULL_UP
          end
        when State::DATA_PULL_UP
          if input == Level::HIGH
            period = 0
            state = State::DATA_PULL_DOWN
          end
        when State::DATA_PULL_DOWN
          if input == Level::LOW
            periods.push(period)
            state = State::DATA_PULL_UP
          end
        end
      end
      return periods
    end

    def calculate_bits(pull_up_periods)
      shortest_period = pull_up_periods.min()
      longest_period = pull_up_periods.max()
      halfway = shortest_period + (longest_period - shortest_period)/2r
      bits = []
      pull_up_periods.each do |period|
        bit = period > halfway
        bits.push(bit)
      end
      bits
    end

    def bits_to_bytes(bits)
      bytes = []
      byte = 0

      bits.each_with_index do |bit, i|
        byte = byte << 1
        byte = byte | (bit ? 1 : 0)
        if (i + 1) % 8 == 0
          bytes.push(byte)
          byte = 0
        end
      end
      bytes
    end

    def calculate_checksum(bytes)
      bytes.slice(0..3).sum & 255
    end

    def bytes_to_temperature(bytes)
      bytes[2]
    end

    def bytes_to_humidity(bytes)
      bytes[0]
    end
  end
end
