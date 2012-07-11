class HTMLDumper

  def initialize(collection)
    @collection = collection
  end
  
  def write(fs)
fs.write("<html><head><title>Log</title>
<style>
table {
  
}

tr {
  font-size: 16px;
}

tr.event {
  background: #eee;
  padding-top: 6px;
  padding-bottom: 6px;
}

tr.message {
  padding-top: 2px;
  padding-bottom: 2px;
}

tr.message td {
  border-bottom: 1px solid #eee;
}

tr.date {
  text-align: center;
  font-weight: bolder;
  font-size: 20px;
}

td {
}

td.date {
  font-weight: bold;
  font-size: 12px;
  
  border-bottom: none;
  border-left: 1px solid #eee;
  padding-left: 3px;
}

td.sender {
  font-weight: bold;
  font-size: 14px;
  
  border-bottom: none;
  border-right: 1px solid #ccc;
  text-align: right;
  
  padding-right: 3px;
}

td.content {
  padding-left: 3px;
  padding-right: 3px;
}


</style>
</head><body>\n")
fs.write("<table>\n")
last_date = nil
last_sender = -1
@collection.entries.each do |entry|
  dt = entry.occurred
  dt = Date.civil(dt.year, dt.month, dt.day)
  
  if dt != last_date
    fs.write("<tr class=\"date\"><td colspan=\"3\">#{dt.to_s}</tr>")
    last_date = dt
  end
  if entry.sender != last_sender
    sender = entry.sender.nil? ? "[NIL]" : "#{entry.sender.name}"
    last_sender = entry.sender
  else
    sender = ""
  end
  content = CGI::escapeHTML((entry.is_action ? "* #{entry.content}" : entry.content))
  fs.write("<tr class=\"#{entry.type}\"><td class=\"sender\">#{sender}</td><td class=\"content\">#{content}</td><td class=\"date\">#{entry.occurred.strftime('%H:%M:%S')}</td></tr>\n")
  #fs.write("<tr class=\"debug\"><td class=\"sender\">DEBUG</td><td class=\"content\">#{CGI::escapeHTML(entry.inspect)}</td><td class=\"date\"></td></tr>\n")
end
fs.write("</table>\n")
fs.write("</body></html>\n")
end

end
