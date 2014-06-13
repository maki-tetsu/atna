module ATNA
  class UdpSender
    def initialize(host, port)
      @host, @port = host, port
      @socket = UDPSocket.open
    end

    def send(datagram)
      @socket.send(datagram, 0, @host, @port)
    end
  end
end
