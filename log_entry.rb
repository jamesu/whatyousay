class LogEntry
  attr_accessor :occurred, :content, :sender, :type, :source
  
  # Types
  # :event => generic event
  # :userDisconnected => disconnected
  # :userAvailable => connected
  # :userLeft => left channel
  # :userNewNickname => new nick
  # :reconnected => you reconnected
  # :message => message
  # :action => /msg or notice
  
  def initialize(entry, sender=nil)
    @sender = sender
    @occurred = entry[:occurred]
    @content = entry[:content] || ''
    @source = entry[:source]
    @type = entry[:type]
  end
  
  def is_action
    @type == :action
  end
  
  def to_loghash(opts={})
    {
      :sender => @sender ? @sender.ident||@sender.name : 'UNKNOWN',
      :occurred => @occurred,
      :content => @content,
      :source => @source,
      :type => @type
    }
  end
  
end
