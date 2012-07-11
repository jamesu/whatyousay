require 'spec_helper'

describe ColloquyParser do
  before do
    @collection = LogCollection.new
    @parser = ColloquyParser.new(@collection)
  end
  
  it "should parse messages" do
    colloquy_data = File.open("spec/fixtures/sample.colloquyTranscript") {|f| f.read}
    xmlDoc = Nokogiri::XML.parse(colloquy_data)
    
    xmlDoc.xpath('log/*').each do |node|
      event = @parser.parse_node(node)
      event.should_not == nil
      
      if node.name == 'envelope'
        event.length.should == node.xpath("*").length-1
      end
    end
  end
  
  it "should accept quit messages" do
    doc = Nokogiri::XML.parse('<event id="VI5I5ZUHY2" name="userDisconnected" occurred="2010-09-02 12:49:53 +0100"><message>JohnSmith disconnected from the server.</message></event>')
    event = @parser.parse_node(doc.children[0])
    event[:type].should == :userDisconnected
    event[:content].should == "JohnSmith disconnected from the server."
    event[:occurred].utc.to_s.should == Time.utc(2010, 9, 2, 11, 49, 53).to_s
    event[:sender].should == nil
  end
  
  it "should accept join messages" do
    doc = Nokogiri::XML.parse('<event id="D1U7LH65IY2" name="userAvailable" occurred="2010-09-02 16:30:17 +0100"><message><span class="member">JohnSmith</span> is now available.</message></event>')
    event = @parser.parse_node(doc.children[0])
    event[:type].should == :userAvailable
    event[:content].should == "JohnSmith is now available."
    event[:occurred].utc.to_s.should == Time.utc(2010, 9, 2, 15, 30, 17).to_s
    event[:sender].should == nil
  end

  it "should handle who events" do
    join = Nokogiri::XML.parse(<<-EOL
    <event id="HELEG6BMEP3" name="memberJoined" occurred="2010-09-02 17:41:53 +0100">
      <message><span class="member">foo</span> joined the chat room.</message>
      <who hostmask="foo@host.com">foo</who>
    </event>
    EOL
    )

    leave = Nokogiri::XML.parse(<<-EOL
      <event id="AGZ4MZINEP3" name="memberParted" occurred="2012-09-02 17:43:53 +0100">
      <message><span class="member">foo</span> left the chat room.</message>
      <who hostmask="foo@host.com">foo</who>
      <reason>Ping timeout: 121 seconds</reason>
    </event>
    EOL
    )

    join_event = @parser.parse_node(join.children[0])
    leave_event = @parser.parse_node(leave.children[0])

    join_event[:type].should == :userAvailable
    join_event[:sender][:ident].should == "foo"

    leave_event[:type].should == :userLeft
    leave_event[:sender][:ident].should == "foo"
  end

  it "should handle by events" do
    op = Nokogiri::XML.parse(<<-EOL
    <event id="APKA3PHJWW3" name="memberPromotedToOperator" occurred="2012-07-02 10:08:13 +0100">
      <message><span class="member">Foo</span> was promoted to operator by <span class="member">ChanServ</span>.</message>
      <who hostmask="Foo@127.0.0.1" identifier="foo" class="operator">Foo</who>
      <by hostmask="ChanServ@services.int" identifier="chanserv" class="server operator">ChanServ</by>
    </event>
    EOL
    )

    op_event = @parser.parse_node(op.children[0])

    op_event[:type].should == :memberPromotedToOperator
    op_event[:sender][:ident].should == "foo"
    op_event[:by][:ident].should == "chanserv"
  end
end