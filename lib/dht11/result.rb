module DHT11
  module Err
    NO_ERROR = :NO_ERROR
    MISSING_DATA = :MISSING_DATA
    CRC = :CRC
  end

  class Result
    attr_reader :temperature, :humidity, :error_code

    def initialize(error_code, temperature, humidity)
      @error_code = error_code
      @temperature = temperature
      @humidity = humidity
    end

    def valid?
      @error_code == Err::NO_ERROR
    end

    def temperature_f
      return Float::NAN if @temperature.nan?
      (@temperature * 9/5) + 32
    end

    alias_method :temp_f, :temperature_f
    alias :temp :temperature
    alias :hum :humidity
  end
end
