class LogEntry
  attr_accessor :occurred, :content, :sender, :by, :type, :source
  
  # Types
  # :event => generic event
  # :userDisconnected => disconnected
  # :userAvailable => connected
  # :userLeft => left channel
  # :userNewNickname => new nick
  # :reconnected => you reconnected
  # :message => message
  # :action => /msg or notice
  
  def initialize(entry, sender=nil, by=nil)
    @sender = sender
    @by = by
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
      :by => @by,
      :type => @type
    }
  end
  
end
