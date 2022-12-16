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

# install yarn
package :yarn do
  add_command 'curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -'
  add_command 'echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list',
    verify: has_file?('/etc/apt/sources.list.d/yarn.list')
  apt_update
  apt_install %w(nodejs yarn)
end

# install the caddy webserver
package :install_caddy do
  apt_install %w(debian-keyring debian-archive-keyring apt-transport-https)
  add_command "curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg", verifier: has_file?('/etc/apt/sources.list.d/caddy-stable.list')
  add_command "curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list", verifier: has_file?('/etc/apt/sources.list.d/caddy-stable.list')

  apt_update
  apt_install %w(caddy)
  directory "/etc/caddy/sites", owner: 'caddy:caddy'
  file "/etc/caddy/Caddyfile", content: "import /etc/caddy/sites/*.caddy", owner: 'caddy:caddy'
  file "/etc/caddy/sites/global.caddy", content: "
    {
      debug
      log {
        output file /var/log/caddy/caddy.log {
          roll_size 10MB
        }
      }
    }
  ", owner: 'caddy:caddy'
  chown '/etc/caddy/*', 'caddy:caddy'
  add_command 'sudo adduser caddy deploy'
  add_command 'sudo service caddy reload'
end

# create a static site
package :my_blog_com do
  directory '/home/deploy/domains/myblog.com/public'
  chown '/home/deploy/domains/myblog.com', 'deploy:deploy', "-R"
  directory '/home/deploy/domains/myblog.com/shared/log', owner: "caddy:caddy"
  file '/etc/caddy/sites/myblog.com.caddy', template: 'myblog.com.caddy'
  chown '/etc/caddy/sites', 'caddy:caddy', "-R"
  add_command "sudo service caddy reload"
end

# create a vhost for a Rails site
package :myrails_site_com do
  directory '/home/deploy/domains/myrails-site.com/'
  chown '/home/deploy/domains/', 'deploy:deploy'
  file '/etc/caddy/sites/myrails-site.com.caddy', template: 'myrails-site.com.caddy'
  chown '/etc/caddy/sites/*', 'caddy:caddy'
  add_command "sudo service caddy reload"
end

# create a systemd service for puma
package :puma_myrails_site do
  directory "/home/deploy/.config/systemd/user/", user: 'deploy'
  chown "/home/deploy/.config", "deploy:deploy", "-R"
  file "/home/deploy/.config/systemd/user/puma_myrails-site.service", owner: 'deploy:deploy', template: 'puma_myrails-site.service'

  directory '/home/deploy/.config/systemd/user/default.target.wants', user: 'deploy'
  symlink "/home/deploy/.config/systemd/user/default.target.wants/puma_myrails-site.service", "/home/deploy/.config/systemd/user/puma_myrails-site.service", user: 'deploy'

  add_command "sudo -u deploy -l systemctl --user daemon-reload"
  add_command "sudo -u deploy -l systemctl --user enable puma_myrails-site"
  add_command "sudo loginctl enable-linger deploy"
end
