require 'spec_helper'

RSpec.describe CodeSnippet::Commands::PrintPath do
  let(:options) { Hashie::Mash.new }
  let(:snippet_dir) { '/path/to/snippets' }

  subject { described_class.new(snippet_dir, options) }

  before do
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    before { subject.run }

    it 'prints given template path to STDOUT' do
      expect(subject)
        .to have_received(:puts)
        .with(snippet_dir)
    end
  end
end
