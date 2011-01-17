class Parser
  attr_accessor :type
  
  def initialize(collection)
    @type = :line
    @collection = collection
  end
  
  def parse(input)
    if @type == :xml
      data = Nokogiri::XML.parse(input.read)
      
      # Parse XML
      data.xpath(@xpath).each do |log_node|
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
    elsif @type == :html
        data = Nokogiri::HTML.parse(input.read)

        # Parse HTML
        data.xpath(@xpath).each do |log_node|
          event = parse_node(log_node)

          unless event.nil?
            if event.is_a?(Array)
              event.each {|evt| @collection.add_event(evt)}
            else
              @collection.add_event(event)
            end
          end
        end
    else
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
  end
  
  def parse_line(line)
  end
  
  def parse_node(node)
  end
end