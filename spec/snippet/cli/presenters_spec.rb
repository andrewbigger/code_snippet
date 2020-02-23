require 'spec_helper'

RSpec.describe Snippet::CLI::Presenters do
  let(:snippets) { [snip, snip] }

  let(:snip) { double(Snippet::Snip) }
  let(:name) { 'snippet' }
  let(:ext) { '.snip' }
  let(:path) { 'path/to/snippet' }
  let(:content) { 'snip-content' }

  before do
    allow(described_class).to receive(:puts).and_return(double)
    allow(snip).to receive(:name).and_return(name)
    allow(snip).to receive(:ext).and_return(ext)
    allow(snip).to receive(:path).and_return(path)
    allow(snip).to receive(:content).and_return(content)
  end
  describe '.pick_from' do
    let(:question) { 'are you sure?' }
    let(:snips) { [snip, snip] }
    let(:prompt) { double(TTY::Prompt) }

    before do
      allow(TTY::Prompt).to receive(:new).and_return(prompt)
      allow(prompt).to receive(:select).and_return(path)
      @choice = subject.pick_from(question, snips)
    end

    it 'asks which path' do
      expect(prompt).to have_received(:select)
        .with(question, [path, path])
    end

    it 'returns chosen path' do
      expect(@choice).to eq snip
    end
  end

  describe '.show' do
    before do
      described_class.show(snip)
    end

    it 'puts content to STDOUT' do
      expect(described_class).to have_received(:puts).with(content)
    end
  end

  describe '.list_snippets' do
    let(:table) { double(TTY::Table) }
    before do
      allow(TTY::Table).to receive(:new).and_return(table)
      allow(table).to receive(:render)
      described_class.list_snippets(snippets)
    end

    it 'sets up render' do
      expect(TTY::Table).to have_received(:new).with(
        %w[NAME LANG PATH],
        [
          [name, ext, path],
          [name, ext, path]
        ]
      )
    end

    it 'renders table' do
      expect(table).to have_received(:render).with(:ascii)
    end
  end
end
