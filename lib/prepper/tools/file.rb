require 'erb'
require 'digest/md5'
module Prepper
  module Tools
    module File
      def self.included(base)
        base.class_eval do

          def chown(path, owner, flags = "")
            @commands << Command.new("chown #{flags} #{owner} #{path}", sudo: true)
          end

          def directory(path, opts = {})
            @commands <<  Command.new("mkdir -p #{path}", opts.merge(sudo: true, verifier: has_directory?(path)))
            @commands <<  Command.new("chown #{opts[:owner]} #{path}", sudo: true) if opts[:owner]
            @commands <<  Command.new("chmod #{opts[:mode]} #{path}", sudo: true) if opts[:mode]
          end

          def has_directory?(path)
            Command.new("test -d #{path}", sudo: true)
          end

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

          def has_file?(path)
            Command.new("test -f #{path}", sudo: true)
          end

          def matches_content?(path, content)
            md5 = Digest::MD5.hexdigest(content)
            Command.new("md5sum #{path} | cut -f1 -d' '`\" = \"#{md5}\"", sudo: true, verifier: has_file?(path))
          end

          def symlink(link, target, opts = {})
            opts.merge!(
              sudo: true,
              verifier: has_symlink?(link)
            )
            @commands << Command.new("ln -s #{target} #{link}", opts)
          end

          def has_symlink?(link, file = nil)
            if file
              Command.new("'#{file}' = `readlink #{link}`")
            else
              Command.new("test -L #{link}", sudo: true)
            end
          end

          def render_template(template, locals)
            ERB.new(::File.read("./templates/#{template}")).result_with_hash(locals)
          end
        end
      end
    end
  end
end
