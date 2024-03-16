require_relative "../app/command"

RSpec.describe Command do
  let(:test) { "haha" }

  it "is expected to run" do
    expect(test).to eq("haha")
  end
end
