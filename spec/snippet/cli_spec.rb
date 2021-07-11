require 'spec_helper'

RSpec.describe CodeSnippet::CLI do
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
