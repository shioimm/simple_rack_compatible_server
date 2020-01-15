class Content
  @@instance = nil
  attr_accessor :body

  def self.instance
    @@instance
  end

  def initialize(body)
    @body = body
    @@instance = self
  end
end
