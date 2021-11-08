require 'spec_helper'

RSpec.describe CodeSnippet::Commands::ShowSnippet do
  let(:snip_name) { 'some-snippet' }
  let(:manager) { double(CodeSnippet::Manager) }
  let(:options) do
    Hashie::Mash.new(
      name: snip_name
    )
  end

  let(:prompt) { double(TTY::Prompt) }

  subject { described_class.new(manager, options) }

  before do
    subject.instance_variable_set(:@prompt, prompt)
  end

  describe '#run' do
    let(:snip_path) { 'path/to/snippet' }
    let(:snip) do
      double(
        CodeSnippet::Snip,
        name: snip_name,
        path: snip_path
      )
    end

    let(:found_snips) { [snip, snip] }
    let(:snip_content) { 'snippet content' }
    let(:snip_names) { [snip_name, snip_name] }

    before do
      allow(prompt).to receive(:select)
        .and_return(snip_name)

      allow(manager)
        .to receive(:snippet_names)
        .and_return(snip_names)

      allow(subject)
        .to receive(:find_snippets)
        .and_return(found_snips)

      allow(subject)
        .to receive(:pick_snippet)
        .and_return(snip)

      allow(snip)
        .to receive(:content)
        .and_return(snip_content)

      allow(Clipboard).to receive(:copy)
      allow(subject).to receive(:puts)

      subject.run
    end

    context 'when name option is provided' do
      it 'finds snippets' do
        expect(subject)
          .to have_received(:find_snippets)
          .with(snip_name)
      end

      it 'prompts user to choose snippet' do
        expect(subject)
          .to have_received(:pick_snippet)
          .with(found_snips)
      end

      it 'prints snippet content' do
        expect(subject)
          .to have_received(:puts)
          .with(snip_content)
      end
    end

    context 'when name option is not provided' do
      let(:options) { Hashie::Mash.new }

      it 'asks user to choose snippet' do
        expect(prompt)
          .to have_received(:select)
          .with(
            'Please choose snippet',
            snip_names
          )
      end

      it 'finds snippets' do
        expect(subject)
          .to have_received(:find_snippets)
          .with(snip_name)
      end

      it 'prompts user to choose snippet' do
        expect(subject)
          .to have_received(:pick_snippet)
          .with(found_snips)
      end

      it 'prints snippet content' do
        expect(subject)
          .to have_received(:puts)
          .with(snip_content)
      end
    end

    context 'when copy flag is provided' do
      let(:options) do
        Hashie::Mash.new(
          copy: true
        )
      end

      it 'copies snippet content to clipboard' do
        expect(Clipboard)
          .to have_received(:copy)
          .with(snip_content)
      end

      it 'prints copied message' do
        expect(subject)
          .to have_received(:puts)
          .with("COPIED: #{snip_path}")
      end
    end
  end

  describe '#find_snippets' do
    let(:snip) { double(CodeSnippet::Snip, name: snip_name) }
    let(:found_snips) { [snip, snip] }

    before do
      allow(manager).to receive(:find).and_return(found_snips)
    end

    context 'when snippet exists' do
      before { @result = subject.find_snippets(snip_name) }

      it 'returns snippets that match the search term' do
        expect(@result).to eq found_snips
      end
    end

    context 'when snippet does not exist' do
      let(:found_snips) { [] }

      it 'raises unable to find snippet runtime error' do
        expect do
          subject.find_snippets(snip_name)
        end.to raise_error(
          RuntimeError,
          "unable to find #{snip_name}"
        )
      end
    end
  end

  describe '#pick_snippet' do
    let(:snip) { double(CodeSnippet::Snip, name: snip_name) }
    let(:found_snips) { [snip, snip] }

    before do
      allow(prompt).to receive(:select).and_return(snip_name)
      allow(manager).to receive(:find).and_return(found_snips)

      @result = subject.pick_snippet(found_snips)
    end

    context 'when there are multiple snippets' do
      it 'prompts user to select a snippet from list' do
        expect(prompt)
          .to have_received(:select)
          .with(
            'Multiple snippets found, which one would you like to view?',
            [snip_name, snip_name]
          )
      end

      it 'finds snippet' do
        expect(manager).to have_received(:find).with(snip_name)
      end

      it 'returns snippet' do
        expect(@result).to eq snip
      end
    end

    context 'when there is one snippet' do
      it 'finds snippet' do
        expect(manager).to have_received(:find).with(snip_name)
      end

      it 'returns snippet' do
        expect(@result).to eq snip
      end
    end
  end
end
