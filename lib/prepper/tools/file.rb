require 'erb'
require 'digest/md5'
module Prepper
  module Tools
    # Helper methods for file and directory management
    module File

      # Changes ownership of a path
      # @param path [String] the path which we want to change the ownership of
      # @param owner [String] name of the owner, ie: 'root:root'
      # @param flags [String] flags to pass to chown, ie: '-R' to do it recursively
      def chown(path, owner, flags = "")
        @commands << Command.new("chown #{flags} #{owner} #{path}", sudo: true)
      end

      # Create a directory unless it already exists
      # @param path [String] path of the directory
      # @param [Hash] opts options hash
      # @option opts [String] :owner Owner of the directory, ie: 'root:root'
      # @option opts [String] :mode mode bits, ie: '0777'
      def directory(path, opts = {})
        @commands <<  Command.new("mkdir -p #{path}", opts.merge(sudo: true, verifier: has_directory?(path)))
        @commands <<  Command.new("chown #{opts[:owner]} #{path}", sudo: true) if opts[:owner]
        @commands <<  Command.new("chmod #{opts[:mode]} #{path}", sudo: true) if opts[:mode]
      end

      # returns a verifier command to test if a directory exists
      # @param path [String] path to test
      def has_directory?(path)
        Command.new("test -d #{path}", sudo: true)
      end

      # Create a file unless it already exists. The contents can be set to a
      # string or a template can be rendered with the provided locals
      # @param path [String] path of the file
      # @param [Hash] opts options hash
      # @option opts [String] :content string content of the file
      # @option opts [String] :template name of the template for the file
      # @option opts [String] :locals hash of variables to pass to the template
      # @option opts [String] :verify_content set to true to verify the file
      #   content is the same in case the file already exists
      # @option opts [String] :owner Owner of the directory, ie: 'root:root'
      # @option opts [String] :mode mode bits, ie: '0777'
      def file(path, opts = {})
        opts[:locals] ||= {}
        opts[:verify_content] ||= true
        content = opts[:content] || render_template(opts[:template], opts[:locals])
        verifier = if opts[:verify_content]
          matches_content?(path, content)
        else
          has_file?(path)
        end
        io = StringIO.new(content)
        @commands << Command.new("put!", {params: [io, path, {owner: opts[:owner], mode: opts[:mode]}], verifier: verifier})
      end

      # returns a verifier command to test if a file exists
      # @param path [String] path to test
      def has_file?(path)
        Command.new("test -f #{path}", sudo: true)
      end

      # returns a verifier command to test if has a matching content
      # @param path [String] path to test
      # @param content [String] expected content
      def matches_content?(path, content)
        md5 = Digest::MD5.hexdigest(content)
        Command.new("md5sum #{path} | cut -f1 -d' '`\" = \"#{md5}\"", sudo: true, verifier: has_file?(path))
      end

      # creates a symlink
      # @param link [String] link
      # @param target [String] target
      # @param [Hash] opts options hash
      def symlink(link, target, opts = {})
        opts.merge!(
          sudo: true,
          verifier: has_symlink?(link)
        )
        @commands << Command.new("ln -s #{target} #{link}", opts)
      end

      # returns a verifier command to test if as a matching content
      # @param path [String] path to test
      # @param content [String] expected content
      def matches_content?(path, content)
        md5 = Digest::MD5.hexdigest(content)
        Command.new("md5sum #{path} | cut -f1 -d' '`\" = \"#{md5}\"", sudo: true, verifier: has_file?(path))
      end

      # creates a symlink
      # @param link [String] link
      # @param target [String] target
      # @param [Hash] opts options hash
      def symlink(link, target, opts = {})
        opts.merge!(
          sudo: true,
          verifier: has_symlink?(link)
        )
        @commands << Command.new("ln -s #{target} #{link}", opts)
      end

      # returns a verifier command to test if symlink exists
      # @param path [String] path to test
      # @param file [String] optionally check if it points to the correct file
      def has_symlink?(link, file = nil)
        if file
          Command.new("'#{file}' = `readlink #{link}`")
        else
          Command.new("test -L #{link}", sudo: true)
        end
      end

      # render an ERB template
      # @param template [String] name of the template
      # @param locals [Hash] hash of variables to pass to the template
      def render_template(template, locals)
        ERB.new(::File.read("./templates/#{template}")).result_with_hash(locals)
      end
    end
  end
end
