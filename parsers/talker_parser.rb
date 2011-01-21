class TalkerParser < Parser
  EVENTYPE_MAP = {
    'leave' => :userDisconnected,
    'join' => :userAvailable,
    'message' => :message
  }
  
  HOSTMASK_MATCH = /([^@]+)@(.*)/
  
  def initialize(collection)
    super(collection)
    
    @current_time = Time.now
    @current_sender = nil
  end
  
  def parse(input)
    event = parse_script(input.read)

    unless event.nil?
      if event.is_a?(Array)
        event.each {|evt| @collection.add_event(evt)}
      else
        @collection.add_event(event)
      end
    end
  end
  
  def parse_event(event)
    room = event['room']
    user = event['user']
    base = {
      :occurred => Time.at(event['time'].to_i),
      :name => EVENTYPE_MAP[event['type']]||:event,
      :source => "talker://#{room['name']}",
      :content => event['content'],
      :sender => {:ident => user['id'], :name => user['name']}
    }
    
    if base[:name] == :userAvailable
      base[:content] = "left"
    elsif base[:name] == :userDisconnected
      base[:content] = "joined"
    end
    
    base
  end
  
  def parse_script(content)
    match = content.match(/var talkerEvents = (\[.*)$/)
    if match
      events = ActiveSupport::JSON.decode(match[1])
      events.map do |event|
        parse_event(event)
      end
    else
      nil
    end
  end
  
  def parse_node(entry)
    parse_script entry.content
  end
end