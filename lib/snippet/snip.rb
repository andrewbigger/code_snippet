module Snippet
  # Snip is a file with a code snippet
  class Snip
    attr_reader :path, :ext

    def self.new_from_file(path)
      new(
        path,
        File.basename(path),
        File.extname(path)
      )
    end

    def initialize(path, name, ext)
      @path = path
      @name = name
      @ext = ext
    end

    def name
      @path
        .gsub("#{CLI.snip_dir}/", '')
        .gsub(@ext, '')
    end

    def exist?
      File.exist?(@path)
    end

    def content
      raise 'cannot read snippet code' unless exist?

      File.read(@path)
    end
  end
end
