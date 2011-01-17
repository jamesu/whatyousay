class BipParser < Parser
  LINE_MATCH = /([0-9][0-9])-([0-9][0-9])-([0-9]{4}) ([0-9][0-9]):([0-9][0-9]):([0-9][0-9]) (.*)/
  USER_MATCH = /([^\!]+)\!([^@]+)@([^: ]+)/
  
  def initialize(collection)
    super(collection)
  end
  
  def reset
  end
  
  def extract_sender(name)
    # either
    # woot!~woot@pool-173-62-200-183.phlapa.fios.verizon.net:
    # OR
    # mgo2.maxgaming.net
    
    user_host = USER_MATCH.match(name)
    if user_host
      {:ident => user_host[2], :name => user_host[1], :host => user_host[3]}
    else
      real_name = (name[-1..-1] == ':') ?  name[0...-1] : name
      {:ident => real_name, :name => real_name, :host => nil}
    end
  end

  def parse_line(content)
    # Bip
    # e.g. 02-03-2010 19:31:31 -!- Afro!~afro@174-22-28-223.eugn.qwest.net has joined #letstalk
    match = LINE_MATCH.match(content)
    if match
      time = Time.utc(match[3].to_i, match[2].to_i, match[1].to_i, 
                      match[4].to_i, match[5].to_i, match[6].to_i)
      words = match[7].split(' ')
      type = words.first
      
      if type == '-!-'
        # System event
        content = words[2..-1].join(' ')
        
        base = {
          :name => :event,
          :sender => extract_sender(words[1]),
          :occurred => time,
          :content => content}
        
        if content.match(/has quit/)
          base[:name] = :userDisconnected
        elsif content.match(/has joined/)
          base[:name] = :userAvailable
        elsif content.match(/is now known as (.*)/)
          #user = $1.match(USER_MATCH)
          base[:name] = :userNewNickname
        elsif content.match(/has left/)
          base[:name] = :userLeft
        end
        
        base
      elsif type[0...1] == '>' or type[0...1] == '<' # > == send, < == recieve
        # User chat
        
        sender = nil
        cnt = nil
        is_action = (words[1] == '*')
        if is_action
          cnt = words[3..-1].join(' ')
          sender = extract_sender(words[2])
        else
          cnt = words[2..-1].join(' ')
          sender = extract_sender(words[1])
        end
        
        return {
          :name => is_action ? :action : :message,
          :sender => sender,
          :occurred => time,
          :content => cnt}
      else
        puts "ERROR >> #{content}"
        nil
      end
    end
  end
end
