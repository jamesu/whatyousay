class Parser
  def initialize(collection)
    @collection = collection
  end
  
  def parse_all_lines(input)
    while true do
       begin
         line = input.readline
       rescue
         break
       end
       
       if line.nil?
         break
       end
       
       event = parse_line(line)
       unless event.nil?
         @collection.add_event(event)
       end
    end
  end
  
  def parse(input)
  end
  
  def parse_line(line)
  end
  
  def parse_node(node)
  end
end