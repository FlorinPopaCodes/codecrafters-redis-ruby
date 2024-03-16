class Parser
  def self.parse(stream)
    case input = stream.gets
    when /^\*/ # Arrays https://redis.io/docs/reference/protocol-spec/#arrays
      items = input.scan(/^\*(\d+)/)[0][0].to_i
      r = []
      items.times do
        r << parse(stream)
      end
      r
    when /^\$/ # Bulk String https://redis.io/docs/reference/protocol-spec/#bulk-strings
      str_len = input.scan(/^\$(\d+)/)[0][0].to_i
      stream.gets[0, str_len]
    else
      # p "unhandled #{input}"
    end
  end
end
