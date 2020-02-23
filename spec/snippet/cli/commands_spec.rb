require 'spec_helper'

RSpec.describe Snippet::CLI::Commands do
  let(:snippet_dir) { 'path/to/snippets' }
  let(:lang) { '.rb' }
  let(:copy) { false }
  let(:vars) { [] }

  before do
    allow(ENV)
      .to receive(:[]).with('SNIPPET_DIR')
                      .and_return(snippet_dir)

    allow(File)
      .to receive(:exist?)
      .with(snippet_dir)
      .and_return(true)
  end

  describe '.show' do
  end

  describe '.list' do
    let(:manager) { double(Snippet::Manager) }
    let(:lang) { nil }

    let(:snip) { double(Snippet::Snip) }
    let(:filtered_snips) { [snip, snip] }
    let(:all_snips) { [snip, snip, snip, snip] }

    before do
      allow(Snippet::CLI).to receive(:snip_dir)
        .and_return('path/to/snips')

      allow(Snippet::Manager)
        .to receive(:new)
        .and_return(manager)

      allow(manager).to receive(:load_snippets)
      allow(manager)
        .to receive(:filter_by_extension)
        .and_return(filtered_snips)

      allow(manager)
        .to receive(:snippets)
        .and_return(all_snips)

      allow(Snippet::CLI::Presenters)
        .to receive(:list_snippets)

      described_class.list(lang, copy, vars)
    end

    it 'loads snippets' do
      expect(manager).to have_received(:load_snippets)
    end

    it 'presents a list of snippets' do
      expect(Snippet::CLI::Presenters)
        .to have_received(:list_snippets)
        .with(all_snips)
    end

    context 'when language filter is applied' do
      let(:lang) { '.rb' }

      it 'presents a list of filtered snippets' do
        expect(Snippet::CLI::Presenters)
          .to have_received(:list_snippets)
          .with(filtered_snips)
      end
    end
  end

  describe '.path' do
    before do
      allow(Snippet::CLI)
        .to receive(:print_message)
        .and_return(nil)

      described_class.path(lang, copy, vars)
    end

    it 'prints snippet dir' do
      expect(Snippet::CLI).to have_received(:print_message)
        .with("SNIPPET_DIR: #{snippet_dir}")
    end
  end
end