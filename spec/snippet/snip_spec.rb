require 'spec_helper'

RSpec.describe Snippet::Snip do
  let(:file_name) { 'snippet-file' }
  let(:file_ext) { '.ext' }
  let(:snip_dir) { 'path/to/snippets' }
  let(:path) { "#{snip_dir}/path/to/#{file_name}#{file_ext}" }

  describe '.new_from_file' do
    before do
      allow(Snippet::CLI).to receive(:snip_dir)
        .and_return(snip_dir)

      @snip = described_class.new_from_file(path)
    end

    it 'creates snip from path' do
      expect(@snip.path).to eq path
      expect(@snip.name).to eq file_name
      expect(@snip.ext).to eq file_ext
    end
  end

  subject { described_class.new_from_file(path) }

  describe '#name' do
    it 'returns file name without snip_dir or file extension' do
      expect(subject.name).to eq file_name
    end
  end

  describe '#exist?' do
    let(:exists) { true }
    before do
      allow(File).to receive(:exist?)
        .with(path)
        .and_return(exists)
    end

    it 'returns true when file exists' do
      expect(subject.exist?).to be true
    end

    context 'when file does not exist' do
      let(:exists) { false }

      it 'returns false' do
        expect(subject.exist?).to be false
      end
    end
  end

  describe '#content' do
    let(:exist) { true }
    let(:content) { 'some-snippet' }

    before do
      allow(subject).to receive(:exist?).and_return(exist)
      allow(File).to receive(:read)
        .with(path)
        .and_return(content)
    end

    it 'returns snippet file content' do
      expect(subject.content).to eq content
    end

    context 'when file does not exist' do
      let(:exist) { false }

      it 'raises error' do
        expect do
          subject.content
        end.to raise_error('cannot read snippet code')
      end
    end
  end
end
