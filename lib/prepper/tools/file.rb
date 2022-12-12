require 'erb'
module Prepper
  module Tools
    module File
      def self.included(base)
        base.class_eval do

          def chown(path, owner, flags = "")
            @commands << Command.new("chown #{flags} #{owner} #{path}", sudo: true)
          end

          def directory(path, opts = {})
            @commands <<  Command.new("mkdir -p #{path}", opts.merge(sudo: true))
            @commands <<  Command.new("chown #{opts[:user]}:#{opts[:user]} #{path}", sudo: true) if opts[:user]
            @commands <<  Command.new("chmod #{opts[:mode]} #{path}", sudo: true) if opts[:mode]
          end

          def has_directory?(path)
            Command.new("-d #{path}", sudo: true)
          end

          def file(path, opts = {})
            opts[:locals] ||= {}
            content = opts[:content] || render_template(opts[:template], opts[:locals])
            io = StringIO.new(content)
            @commands << Command.new("put!", {params: [io, path, {owner: opts[:owner], mode: opts[:mode]}]})
          end

          def has_file?(path)
            Command.new("-f #{path}", sudo: true)
          end

          def matches_content?(path, content)

          end

          def render_template(template, locals)
            ERB.new(::File.read("./templates/#{template}")).result_with_hash(locals)
          end
        end
      end
    end
  end
end
