require 'spec_helper'

RSpec.describe CodeSnippet::Commands::PrintVersion do
  let(:options) { Hashie::Mash.new }

  subject { described_class.new(options) }

  before do
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    before { subject.run }

    it 'prints current version to STDOUT' do
      expect(subject)
        .to have_received(:puts)
        .with(CodeSnippet::VERSION)
    end
  end
end
