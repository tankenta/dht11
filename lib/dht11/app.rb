module DHT11
  class App
    DEFAULT_PIN_BCM = 26

    def run!
      dht = Sensor.new(DEFAULT_PIN_BCM)
      loop do
        result = dht.read
        puts "Temperature: #{result.temperature}, Humidity: #{result.humidity}"
        sleep 2
      end
    end
  end
end

DHT11::App.new.run!
