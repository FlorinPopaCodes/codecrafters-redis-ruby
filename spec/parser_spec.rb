require_relative '../app/parser'

RSpec.describe Parser do
  subject(:parser) { Parser.new }

  let(:io_stream) do
    double('IOStream')
  end

  before do
    line = 0
    allow(io_stream).to receive(:gets) do
      r = socket_response[line]
      line += 1
      r
    end
  end

  context 'SET ECHO 1' do
    let(:socket_response) do
      %W[*3\r\n $3\r\n set\r\n $4\r\n echo\r\n $1\r\n 1\r\n]
    end

    it 'is expected to run' do
      expect(parser.parse(io_stream)).to eq(%w[set echo 1])
    end
  end

  context "PING\nPING\nPING" do
    let(:socket_response) do
      %W[*1\r\n $4\r\n ping\r\n *1\r\n $4\r\n ping\r\n *1\r\n $4\r\n ping\r\n]
    end

    it 'is expected to run' do
      expect(parser.parse(io_stream)).to eq(['ping'])
    end
  end
end
