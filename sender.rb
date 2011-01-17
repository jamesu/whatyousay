class Sender
  attr_accessor :ident, :name, :hostmask
  
  def initialize(ident, name, hostmask)
    @ident = ident
    @name = name
    @hostmask = hostmask
  end
  
  def merge(sender)
    self
  end
  
  def to_loghash
    {
      :ident => @ident,
      :name => @name,
      :hostmask => @hostmask
    }
  end
end