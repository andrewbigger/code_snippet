module Snippet
  class Manager
    DEFAULT_QUERY = ->(snip) { return true }
    
    attr_reader :snippets

    def initialize(snippet_dir)
      @snippet_dir = snippet_dir
      @snippets = []
    end

    def load_snippets
      Dir.glob(File.join(@snippet_dir, '**', '*')).each do |file|
        next if File.directory?(file)

        @snippets << Snippet::Snip.new_from_file(file)
      end
    end

    def filter(query = DEFAULT_QUERY )
      @snippets.select do |snip|
        query.call(snip)
      end
    end

    def find(search_term, lang = nil)
      name_query = -> (snip) do
        snip.name.include?(search_term)
      end

      results = filter(name_query)

      unless lang.nil?
        results = results.select do |snip|
          snip.ext == lang
        end
      end

      results
    end

    def filter_by_extension(ext)
      ext = ".#{ext}" unless ext.start_with?('.')

      ext_query = -> (snip) { snip.ext == ext }
      filter(ext_query)
    end
  end
end
