class FTPResponse
  def initialize(code, message)
    @code = code
    @message = message
  end

  def to_s
    "#{@code.to_s} #{@message}"
  end

end

class FTPResponse200 < FTPResponse
  def initialize(message='OK')
    super(200, message)
  end
end

class FTPResponse250 < FTPResponse
  def initialize(message='Requested file action completed')
    super(250, message)
  end
end

class FTPResponse425 < FTPResponse
  def initialize(message='Can\'t open data connection.')
    super(425, message)
  end
end

class FTPResponse500 < FTPResponse
  def initialize(message='Error')
    super(500, message)
  end
end

class FTPResponse502 < FTPResponse
  def initialize(message='Command not implemented')
    super(502, message)
  end
end

class FTPResponseSystem < FTPResponse
  def initialize(message='UNIX')
    super(215, message)
  end
end

class FTPResponseFeatures < FTPResponse
  def initialize(message='UNIX')
    super(211, "-Exensions supported:\r\n UTF8\r\n211 End")
  end

  def to_s
    "#{@code.to_s}#{@message}"
  end
end

class FTPResponseGreet < FTPResponse
  def initialize(message='Welcome to VolcanoFTP server')
    super(220, message)
  end
end

class FTPResponseGoodbye < FTPResponse
  def initialize(message='Good bye!')
    super(221, message)
  end
end