class LogCollection
  attr_accessor :entries
  attr_accessor :senders
  attr_accessor :source
  
  def initialize
    @entries = []
    @senders = {}
    @source = nil
  end
  
  def add_sender(sender)
    idt = sender[:ident]
    
    if idt
      if @senders.has_key? idt
        @senders[idt].merge(sender)
      else
        @senders[idt] = Sender.new(idt, sender[:name], sender[:hostmask])
      end
    else
      # Look for sender[:name]/sender[:old_name]
      name = sender[:old_name]||sender[:name]
      matched_senders = @senders.select do |k, v|
        if v.name == name
          true
        else
          false
        end
      end
      matched_senders.first ? matched_senders.first[1] : nil
    end
  end
  
  def add_event(data)
    sender = if data[:sender]
      add_sender(data[:sender])
    else
      nil
    end
    
    log_entry = LogEntry.new(data, sender)
    log_entry.source = @source
    
    @entries << log_entry
  end

  def limit_entries_by_time(start_time, end_time)
    return if (start_time.nil? && end_time.nil?)
    @entries.reject! do |entry|
      if (start_time.nil? or entry.occurred >= start_time) && (end_time.nil? or entry.occurred < end_time)
        false
      else
        true
      end
    end
  end
  
  def clean_entries
    @entries.sort! { |x,y| x.occurred <=> y.occurred }
    
    last_entry = nil
    @entries.reject! do |entry|
      unless last_entry.nil?
        rej = if entry.occurred == last_entry.occurred &&
                 entry.sender == last_entry.sender &&
                 entry.content.strip == last_entry.content.strip
          puts "Rejected duplicate..."
          puts entry.content
          puts last_entry.content
          true
        else
          false
        end
      end

      last_entry = entry
      rej
    end
  end
  
  
end