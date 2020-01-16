require 'spec_helper'

RSpec.describe Snippet::Manager do
  let(:snippet_dir) { 'path/to/snippets' }

  subject do
    described_class.new(snippet_dir)
  end

  describe '#load_snippets' do
    let(:directory) { File.join(snippet_dir, 'path/to/dir') }
    let(:file)      { File.join(snippet_dir, 'path/to/dir/file') }

    let(:file_snip) { double(Snippet::Snip) }
    let(:files) do
      [
        directory,
        directory,
        file,
        file
      ]
    end

    before do
      allow(File).to receive(:directory?).with(directory)
                                         .and_return(true)

      allow(File).to receive(:directory?).with(file)
                                         .and_return(false)

      allow(Dir).to receive(:glob).and_return(files)
      allow(Snippet::Snip).to receive(:new_from_file)
        .and_return(file_snip)

      subject.load_snippets
    end

    it 'creates snips from files' do
      expect(subject.snippets.count).to be 2

      subject.snippets.each do |snip|
        expect(snip).to eq file_snip
      end
    end
  end

  describe '#filter' do
    let(:query) do
      ->(snip) { snip == target_snip }
    end

    let(:snip) { double(Snippet::Snip) }
    let(:target_snip) { double(Snippet::Snip) }

    let(:snips) do
      [
        snip,
        snip,
        target_snip
      ]
    end

    before do
      subject.instance_variable_set(:@snippets, snips)
      @result = subject.filter(query)
    end

    it 'finds target snip in set' do
      expect(@result.count).to be 1
      expect(@result.first).to eq target_snip
    end

    context 'when no query is defined' do
      before do
        @results = subject.filter
      end

      it 'returns everything' do
        expect(@results.count).to eq 3
      end
    end
  end

  describe '#find' do
    let(:search_term) { 'foo' }
    let(:lang) { '.rb' }

    let(:snip) do
      Snippet::Snip.new('path/to/snip.rb', 'snip.rb', '.rb')
    end

    let(:target_snip) do
      Snippet::Snip.new('path/to/snip.rb', 'foo.rb', '.rb')
    end

    let(:almost_target_snip) do
      Snippet::Snip.new('path/to/snip.rb', 'foo.go', '.go')
    end

    let(:snips) do
      [
        snip,
        snip,
        target_snip,
        almost_target_snip
      ]
    end

    before do
      subject.instance_variable_set(:@snippets, snips)
      @result = subject.find(search_term, lang)
    end

    it 'returns expected snip' do
      expect(@result.count).to be 1
      expect(@result.first).to eq target_snip
    end

    context 'when language filter is not provided' do
      let(:lang) { nil }

      it 'returns expected snips' do
        expect(@result.count).to be 2
        expect(@result[0]).to be target_snip
        expect(@result[1]).to be almost_target_snip
      end
    end
  end

  describe '#filter_by_extension' do
    let(:search_term) { 'foo' }
    let(:lang) { '.rb' }

    let(:snip) do
      Snippet::Snip.new('path/to/snip.rb', 'snip.go', '.go')
    end

    let(:target_snip) do
      Snippet::Snip.new('path/to/snip.rb', 'foo.rb', '.rb')
    end

    let(:another_target_snip) do
      Snippet::Snip.new('path/to/snip.rb', 'bar.rb', '.rb')
    end

    let(:snips) do
      [
        snip,
        snip,
        target_snip,
        another_target_snip
      ]
    end

    before do
      subject.instance_variable_set(:@snippets, snips)
      @result = subject.filter_by_extension(lang)
    end

    it 'returns files matching extension' do
      expect(@result.count).to be 2
      expect(@result[0]).to be target_snip
      expect(@result[1]).to be another_target_snip
    end
  end
end
