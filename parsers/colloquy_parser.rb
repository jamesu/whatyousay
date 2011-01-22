class ColloquyParser < Parser
  EVENTYPE_MAP = {
    'userDisconnected' => :userDisconnected,
    'userAvailable' => :userAvailable,
    'memberParted' => :userLeft,
    'memberJoined' => :userAvailable,
    'userLeft' => :userLeft,
    'userNewNickname' => :userNewNickname,
    'reconnected' => :reconnected,
    'disconnected' => :disconnected
  }
  
  HOSTMASK_MATCH = /([^@]+)@(.*)/
  
  def initialize(collection)
    super(collection)
    
    @current_time = Time.now
    @current_sender = nil
  end
  
  def parse(input)
    data = Nokogiri::XML.parse(input.read)
    
    # Parse XML
    data.xpath('log').each do |log_node|
      @collection.source = log_node['source']
      log_node.xpath('*').each do |node|
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
  end
  
  def parse_node(entry)
    content = nil
    time = nil
    xpath = entry.xpath("sender").first
    sender = xpath ? {:ident => xpath["identifier"],
                      :name => xpath.inner_text,
                      :hostmask => xpath["hostmask"]} : @current_sender
    @current_sender = sender
    
    if sender && sender[:ident].nil? && sender[:hostmask]
      # match from hostmask
      match = sender[:hostmask].match(HOSTMASK_MATCH)
      sender[:ident] = match[1]
    end
    
    entry_type = entry.name
    
    if entry.name == "event":
      time = Time.parse(entry["occurred"])
      content = entry.xpath("message").inner_text
      reason = entry.xpath("reason")
      if reason && !reason.inner_text.empty?
        content = "#{content} (#{reason.inner_text})"
      end
      entry_type = EVENTYPE_MAP[entry["name"]]||(entry["name"].to_sym)
      
      if entry_type == :userNewNickname
        sender[:old_name] = entry.xpath("old").inner_text
      end
    elsif entry.name == "message"
      time = Time.parse(entry["received"])
      content = entry.inner_text
    elsif entry.name == "envelope"
      return entry.xpath("message").map do |sub_entry|
        parse_node(sub_entry)
      end
    else
      time = nil
      content = "???"
    end
      
    {:type => entry_type,
      :sender => sender,
      :source => nil,
      :occurred => time,
      :content => content
    }
  end
end