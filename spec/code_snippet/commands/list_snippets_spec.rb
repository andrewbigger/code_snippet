require 'spec_helper'

RSpec.describe CodeSnippet::Commands::ListSnippets do
  let(:options) { Hashie::Mash.new }

  let(:snippet_list_table) do
    <<~TABLE
      NAME         LANG
      some-snippet .go
    TABLE
  end

  let(:manager) { double(CodeSnippet::Manager) }
  let(:snippets) { [snippet] }

  let(:snip_name) { 'some-snippet' }
  let(:snip_ext) { '.go' }

  let(:snippet) do
    double(
      CodeSnippet::Snip,
      name: snip_name,
      ext: snip_ext,
      content: 'stuff'
    )
  end

  subject { described_class.new(manager, options) }

  before do
    allow(manager)
      .to receive(:snippets)
      .and_return(snippets)

    allow(snippet)
      .to receive(:name)
      .and_return(snip_name)

    allow(snippet)
      .to receive(:ext)
      .and_return(snip_ext)

    allow(TTY::Table).to receive(:new).and_call_original
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    before { subject.run }

    it 'retrieves snippets from manager' do
      expect(manager).to have_received(:snippets)
    end

    it 'renders table' do
      expect(TTY::Table).to have_received(:new).with(
        header: CodeSnippet::Commands::ListSnippets::RESULT_HEADER,
        rows: [['some-snippet', '.go']]
      )
    end

    it 'prints table to STDOUT' do
      expect(subject)
        .to have_received(:puts)
        .with(snippet_list_table.strip)
    end
  end
end
