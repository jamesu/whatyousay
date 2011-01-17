class IrciiParser < Parser
  attr_accessor :current_time
  
  LINE_MATCH = /^([0-9][0-9]):([0-9][0-9]) (.*)/
  SYS_USER_HOST_MATCH = /([A-Za-z0-9\-\[\]'`\^{}]+) \[([^@]+)@([^\]]+)\] (.*)/
  DATE_MATCH = /([A-Za-z]+) ([A-Za-z]+) ([0-9]{1,2}) ([0-9][0-9]):([0-9][0-9]):([0-9][0-9]) ([0-9]{1,4})/
  LOOSE_DATE_MATCH = /([A-Za-z]+) ([A-Za-z]+) ([0-9]{1,2}) ([0-9]{1,4})/
  MONTH_MAP = {
    'Jan' => 1,
    'Feb' => 2,
    'Mar' => 3,
    'Apr' => 4,
    'May' => 5,
    'Jun' => 6,
    'Jul' => 7,
    'Aug' => 8,
    'Sep' => 9,
    'Oct' => 10,
    'Nov' => 11,
    'Dec' => 12 }
  
  def initialize(collection)
    super(collection)
    @current_time = Time.now
  end
  
  # returns [sender, content, is_action]
  def extract_message(input)
    sender = nil
    content = nil
    is_action = false
    
    stripped = input.strip
    if stripped[0...1] == '*'  # action
      is_action = true
      stripped = stripped[1..-1].split(' ')
      sender = stripped[0]
      content = stripped[1..-1].join(' ')
    else
      scanned = /<([^>]*)> (.*)/.match(stripped)
      sender = scanned[1].strip
      content = scanned[2]
    end
    
    [{:ident => sender, :name => sender, :host => nil}, content, is_action]
  end

  def parse_line(content)
    # e.g. 14:14 -!- KrimZon [~krimzon@188-221-214-2.zone12.bethere.co.uk] has quit [Quit: The rat the cat the dog bit chased escaped]
    match = LINE_MATCH.match(content)
    if match
      time = Time.utc(@current_time.year, @current_time.month, @current_time.day, 
                      match[1].to_i, match[2].to_i, 0)
      words = match[3].split(' ')
      type = words.first
      
      if type == '-!-' or type[0...1] == '!'
        # System event
        
        # User?
        user_match = SYS_USER_HOST_MATCH.match(words[1..-1].join(' '))
        if user_match
          # i.e. Foo [...] has done something
          base = {
            :name => :event,
            :sender => {:ident => user_match[2], :name => user_match[1], :host => user_match[3]},
            :occurred => time,
            :content => user_match[4] }
          
          if user_match[4].match(/has quit/)
            base[:name] = :userDisconnected
          elsif user_match[4].match(/has joined/)
            base[:name] = :userAvailable
          elsif user_match[4].match(/has left/)
            base[:name] = :userLeft
          end
          
          base
        else
          # i.e. ???
          return {
            :name => :event,
            :sender => {:ident => words[0], :name => words[0], :host => nil},
            :occurred => time,
            :content => words[1..-1].join(' ')}
        end
      else
        # User chat / action
        chat = extract_message(match[3])
        return {
          :name => chat[2] ? :action : :message,
          :sender => chat[0],
          :occurred => time,
          :content => chat[1]}
      end
    elsif content[0...3] == '---'
      # Log details
      date = DATE_MATCH.match(content)
      if date
        @current_time = Time.utc(date[7].to_i, MONTH_MAP[date[2]], date[3].to_i, 
                                 date[4].to_i, date[5].to_i, date[6].to_i)
      else
        date = LOOSE_DATE_MATCH.match(content)
        if date
          @current_time = Time.utc(date[4].to_i, MONTH_MAP[date[2]], date[3].to_i)
        else
          puts "ERROR!! >> #{content}"
        end
      end
      
      nil
    end
  end
end