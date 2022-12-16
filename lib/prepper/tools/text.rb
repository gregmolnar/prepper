module Prepper
  module Tools
    module Text
      def append_text(text, path)
        @commands << Command.new("/bin/echo -e '#{text}' | sudo tee -a #{path}", verifier: has_text?(text, path))
      end

      def has_text?(text, path)
        regex = Regexp.escape(text)
        Command.new("grep -qPzo '^#{regex}$' #{path} ||", sudo: true)
      end
    end
  end
end
