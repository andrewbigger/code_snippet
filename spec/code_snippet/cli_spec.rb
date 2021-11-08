require 'spec_helper'

RSpec.describe CodeSnippet::CLI do
  let(:options) { Hashie::Mash.new }
  let(:snip_dir) { 'path/to/snippets' }
  let(:snip_exist) { true }
 
  subject { described_class.new }

  before do
    allow(subject).to receive(:options)
      .and_return(options)
  end

  describe '#version' do
    let(:command) { double }

    before do
      allow(command).to receive(:run)
      allow(CodeSnippet::Commands::PrintVersion)
        .to receive(:new)
        .and_return(command)

      subject.version
    end

    it 'passes options to command' do
      expect(CodeSnippet::Commands::PrintVersion)
        .to have_received(:new).with(options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#path' do
    let(:command) { double }

    before do
      allow(ENV)
      .to receive(:[])
      .with('SNIPPET_DIR')
      .and_return(snip_dir)

    allow(File)
      .to receive(:exist?)
      .with(snip_dir)
      .and_return(snip_exist)

      allow(command).to receive(:run)
      allow(CodeSnippet::Commands::PrintPath)
        .to receive(:new)
        .and_return(command)

      subject.path
    end

    it 'passes snip_dir and options to command' do
      expect(CodeSnippet::Commands::PrintPath)
        .to have_received(:new).with(snip_dir, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#show' do
    let(:command) { double }
    let(:manager) { CodeSnippet::Manager }

    before do
      allow(command).to receive(:run)
      allow(subject)
        .to receive(:manager)
        .and_return(manager)

      allow(CodeSnippet::Commands::ShowSnippet)
        .to receive(:new)
        .and_return(command)

      subject.show
    end

    it 'passes manager and options to command' do
      expect(CodeSnippet::Commands::ShowSnippet)
        .to have_received(:new).with(manager, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#list' do
    let(:command) { double }
    let(:manager) { CodeSnippet::Manager }

    before do
      allow(command).to receive(:run)
      allow(subject)
        .to receive(:manager)
        .and_return(manager)

      allow(CodeSnippet::Commands::ListSnippets)
        .to receive(:new)
        .and_return(command)

      subject.list
    end

    it 'passes manager and options to command' do
      expect(CodeSnippet::Commands::ListSnippets)
        .to have_received(:new).with(manager, options)
    end

    it 'runs command' do
      expect(command).to have_received(:run)
    end
  end

  describe '#snip_dir' do
    let(:snip_dir) { 'path/to/snippet/dir' }
    let(:snip_dir_exist) { false }

    before do
      allow(ENV)
        .to receive(:[])
        .with('SNIPPET_DIR')
        .and_return(snip_dir)

      allow(File)
        .to receive(:exist?)
        .and_return(snip_dir_exist)
    end

    context 'when environment variable not set' do
      let(:snip_dir) { nil }

      it 'raises env var not set runtime error' do
        expect do
          subject.snip_dir
        end.to raise_error(
          RuntimeError,
          'SNIPPET_DIR environment variable not set'
        )
      end
    end

    context 'when snippet directory does not exist' do
      it 'raises env var not exist runtime error' do
        expect do
          subject.snip_dir
        end.to raise_error(
          RuntimeError,
          "SNIPPET_DIR #{snip_dir} does not exist"
        )
      end
    end

    context 'when environment variable set and directory exists' do
      let(:snip_dir_exist) { true }

      it 'returns snippet dir' do
        expect(subject.snip_dir).to eq snip_dir
      end
    end
  end

  describe '#manager' do
    let(:snip_dir) { 'path/to/snip/dir' }
    let(:manager) { double(CodeSnippet::Manager) }

    before do
      allow(subject)
        .to receive(:snip_dir)
        .and_return(snip_dir)

      allow(CodeSnippet::Manager)
        .to receive(:new)
        .and_return(manager)

      allow(manager).to receive(:load)

      @manager = subject.manager
    end

    it 'creates a new snip with snip dir' do
      expect(CodeSnippet::Manager)
        .to have_received(:new)
        .with(snip_dir)
    end

    it 'loads manager' do
      expect(manager).to have_received(:load)
    end

    it 'returns manager' do
      expect(@manager).to eq manager
    end
  end
end
