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

  describe '.snippet_path' do
    before do
      allow(Snippet::CLI)
        .to receive(:print_message)
        .and_return(nil)

      described_class.snippet_path(lang, copy, vars)
    end

    it 'prints snippet dir' do
      expect(Snippet::CLI).to have_received(:print_message)
        .with("SNIPPET_DIR: #{snippet_dir}")
    end
  end
end

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

RSpec.describe Snippet::CLI do
  let(:logger) { double(Logger) }
  let(:message) { 'lorem ipsum' }

  before do
    allow(described_class).to receive(:exit).and_return(double)
  end

  describe '.snip_dir' do
    let(:snippet_dir) { 'path/to/snippets' }
    let(:exists) { true }

    before do
      allow(ENV)
        .to receive(:[])
        .with('SNIPPET_DIR')
        .and_return(snippet_dir)

      allow(File).to receive(:exist?).and_return(exists)
    end

    it 'returns path to snippets' do
      expect(described_class.snip_dir).to eq snippet_dir
    end

    context 'when the environment variable is not set' do
      let(:snippet_dir) { nil }

      it 'raises error' do
        expect do
          described_class.snip_dir
        end.to raise_error 'SNIPPET_DIR environment variable not set'
      end
    end

    context 'when the snippet directory does not exist' do
      let(:exists) { false }

      it 'raises error' do
        expect do
          described_class.snip_dir
        end.to raise_error "SNIPPET_DIR #{snippet_dir} does not exist"
      end
    end
  end

  describe '.logger' do
    before do
      allow(Logger).to receive(:new).and_return(logger)
      allow(logger).to receive(:formatter=)
      @logger = subject.logger
    end

    it 'creates a new logger to STDOUT' do
      expect(Logger).to have_received(:new).with(STDOUT)
    end
  end

  describe '.print_message' do
    let(:logger) { double(Logger) }

    before do
      allow(described_class).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info)
      described_class.print_message(message)
    end

    it 'prints message to stdout' do
      expect(logger).to have_received(:info).with(message)
    end
  end

  describe '.print_message_and_exit' do
    let(:exit_code) { 2 }

    before do
      allow(described_class).to receive(:print_message)
      described_class.print_message_and_exit(message, exit_code)
    end

    it 'prints message' do
      expect(described_class).to have_received(:print_message).with(message)
    end

    it 'exits with set status' do
      expect(described_class).to have_received(:exit).with(exit_code)
    end
  end
end
