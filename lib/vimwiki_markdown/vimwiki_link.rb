# This class takes in a string of a markdown link and spits out
# a correctly formed markdown link, with absolute and relative
# links to markdown files correctly altered.
#
# The main thing we're working around is that markdown files can
# be linked to with (or without) an extension. That and we're also
# rewiring the filenames to be parameterized


module VimwikiMarkdown
  class VimwikiLink
    MARKDOWN_LINK_REGEX = /\[(?<title>.*)\]\((?<uri>(?:(?!#).)*)(?<fragment>(?:#)?.*)\)/

    attr_reader :title, :uri, :fragment, :source_markdown_directory, :markdown_extension, :root_path

    def initialize(markdown_link, source_markdown_filepath, markdown_extension, root_path)
      @title = markdown_link.match(MARKDOWN_LINK_REGEX)[:title]
      @uri = markdown_link.match(MARKDOWN_LINK_REGEX)[:uri]
      @fragment = markdown_link.match(MARKDOWN_LINK_REGEX)[:fragment]
      @markdown_extension = markdown_extension
      @root_path = root_path
      @source_markdown_directory = Pathname.new(source_markdown_filepath).dirname
      rewrite_local_links!
    end


    def to_s
      "[#{title}](#{uri}#{fragment})"
    end

    private

    def rewrite_local_links!
      if vimwiki_markdown_file_exists?
        path = Pathname.new(uri)
        @uri = "#{path.dirname + path.basename(markdown_extension).to_s.parameterize}.html"
        @fragment = "#{fragment.empty? ? '' : '#' + fragment.parameterize}"
      end
    end

    def vimwiki_markdown_file_exists?
      File.exist?((source_markdown_directory + uri).sub_ext(markdown_extension)) ||
      absolute_path_to_markdown_file_exists?
    end

    def absolute_path_to_markdown_file_exists?
      path = Pathname(uri)
      filepath = Pathname.new(source_markdown_directory + root_path + path.to_s.sub(/^\//,"")).
                 sub_ext(markdown_extension)

      path.absolute? && File.exist?(filepath)
    end
  end
end
