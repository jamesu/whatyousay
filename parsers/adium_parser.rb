class AdiumParser < Parser
  # i.e. parses logs in ~/Library/Application Support/Adium 2.0/Users/Default/Logs/**.chatlog
  STATUSTYPE_MAP = {
    'away' => :userAvailable,
    'return_away' => :userLeft,
    'online' => :userAvailable,
    'offline' => :userLeft,
    'idle' => nil,
    'return_idle' => nil,
    'away_message' => nil,
    'mobile' => nil,
    'return_mobile' => nil
  }

  EVENT_MAP = {
    'windowClosed' => :userDisconnected,
    'windowOpened' => :userAvailable
  }

  EVENT_DESC = {
    'windowClosed' => '[Closed the window]',
    'windowOpened' => '[Opened the window]'
  }

  # Format of adium logs:
  # <chat>
  #   <status></status> ; <message></message> <action></action> ; <event></event>
  
  HOSTMASK_MATCH = /([^@]+)@(.*)/
  
  def initialize(collection)
    super(collection)
    
    @current_time = Time.now
    @current_sender = nil
  end
  
  def parse(input)
    data = Nokogiri::XML.parse(input.read)
    
    chat_info = data.root
    @collection.source = "#{chat_info['account']} #{chat_info['service']}"

    # Parse XML
    chat_info.xpath('*').each do |node|
      event = parse_node(node)
      unless event.nil?
        if event.is_a?(Array)
          event.each {|evt| @collection.add_event(evt)}
        else
          @collection.add_event(event)
        end
      end
    end
  end

  def parse_node(entry)
    time = Time.parse(entry['time']) rescue nil
    sender = {:name => entry['alias']||entry['name'],
              :ident => entry['sender'],
              :alias => entry['name']||entry['alias'],
              :hostmask => entry['sender']}

    content = entry.inner_text
    by = nil

    case entry.name
    when 'action'
      # sender, time, [alias]
      entry_type = :action

    when 'message'
      # sender, time, [alias]
      entry_type = :message

    when 'status'
      # contact status
      # type, sender, time
      status_type = entry['type']
      entry_type = :event
      case status_type
      when 'purple'
        # leaving / joining room
        entry_type = :event
      else
        # contact disconnection
        entry_type = STATUSTYPE_MAP[entry['type']]||:event
      end
    when 'event'
      # type= windowOpened, windowClosed, 
      entry_type = EVENT_MAP[entry['type']]||:event
      content = EVENT_DESC[entry['type']]||''
      type = :action
    else
      # Unknown
      puts "Warning: unknown node #{entry.name}"
    end
      
    outs = {:type => entry_type,
      :sender => sender,
      :by => by,
      :source => nil,
      :occurred => time,
      :content => content
    }

    outs
  end
end