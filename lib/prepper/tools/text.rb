module Prepper
  module Tools
    # text related helpers
    module Text
      # append text to a file
      # @param text [String] text to append
      # @param path [String]
      def append_text(text, path)
        @commands << Command.new("/bin/echo -e '#{text}' | sudo tee -a #{path}", verifier: has_text?(text, path))
      end

      # returns a verifier command to test the presence of a string in a file
      # @param text [String] text
      # @param path [String] path to file
      def has_text?(text, path)
        regex = Regexp.escape(text)
        Command.new("grep -qPzo '^#{regex}$' #{path} ||", sudo: true)
      end
    end
  end
end
