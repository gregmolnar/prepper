# Prepper

Prepper is a simple server provisioning tool, built on top of SSHKit. You can
use it to script your server build process.


## Installation

    $ gem install prepper

## Usage

Prepper works with "packages". You define a package with a name and pass it a block.
Within that block you can execute commands on the target host.
There are built in helpers to install `apt` packages, manage directories and
upload files to the server, etc.

A simple example:

```ruby

server_host "YOUR_SERVER_IP"
server_port 22
server_user "root"

# let's install the necessary packages to run a Rails app with Postgresql
package :apt do
  apt_update
  apt_install %w(git-core build-essential libcurl4 libcurl4-openssl-dev libjemalloc-dev postgresql-client libpq-dev postgresql-contrib)
end

# now we will add a deploy user
package :add_deploy_user do
  add_user 'deploy', shell: '/bin/bash', flags: '--disabled-password'

  directory '/home/deploy/.ssh', owner: 'deploy:deploy'
  file '/home/deploy/.ssh/authorized_keys', owner: 'deploy:deploy', mode: '655', content: 'ssh-rsa YOUR PUBLIC SSH KEY'
  file '/etc/sudoers.d/deploy', owner: 'root:root', template: 'sudoers'
end

# install rbenv and Ruby 3.1.2
package :install_ruby do
  install_rbenv 'deploy'
  install_ruby 'deploy', '3.1.2', '--with-jemalloc'
end

```

You can see a full example in [examples/config.rb](examples/config.rb). You would run that file with `bundle exec prepper config.rb` to provision the server.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/prepper. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/prepper/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Prepper project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/prepper/blob/master/CODE_OF_CONDUCT.md).
