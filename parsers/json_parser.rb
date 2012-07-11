class JSONParser < Parser

  def initialize(collection)
    super(collection)
  end

  def parse(input)
    data = ActiveSupport::JSON.decode(input.read)
    data['senders'].each do |sender|
      @collection.senders[sender['ident']] = Sender.new(sender['ident'],
                                                        sender['name'],
                                                        sender['hostmask'])
    end
    
    data['entries'].each do |entry|
      @collection.entries << LogEntry.new({
        :occurred => Time.parse(entry['occurred']),
        :content => entry['content'],
        :source => entry['source'],
        :type => entry['type'].to_sym
      }, @collection.senders[entry['sender']], @collection.senders[entry['by']])
    end
  end
end