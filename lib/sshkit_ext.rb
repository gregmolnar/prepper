require 'sshkit'
SSHKit::Backend::Netssh.class_eval do
  # Uploads the given string or file-like object to the current host
    # context. Accepts :owner and :mode options that affect the permissions of the
    # remote file.
    #
    def put!(string_or_io, remote_path, opts={})
      sudo_exec = ->(*cmd) {
        cmd = [:sudo] + cmd if opts[:sudo]
        execute *cmd
      }

      tmp_path = "/tmp/#{SecureRandom.uuid}"

      owner = opts[:owner]
      mode = opts[:mode]

      source = if string_or_io.respond_to?(:read)
        string_or_io
      else
        StringIO.new(string_or_io.to_s)
      end

      sudo_exec.call :mkdir, "-p", File.dirname(remote_path)

      upload!(source, tmp_path)

      sudo_exec.call(:mv, "-f", tmp_path, remote_path)
      sudo_exec.call(:chown, owner, remote_path) if owner
      sudo_exec.call(:chmod, mode, remote_path) if mode
    end

end
