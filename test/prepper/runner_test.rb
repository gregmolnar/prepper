require "test_helper"

class RunnerTest < Minitest::Test
  def test_it_runs
    assert Prepper::Runner.new("")
  end

  def test_it_sets_host
    code = <<-CODE
    server_host "test.com"
    CODE
    runner = Prepper::Runner.new(code)
    assert_equal('test.com', runner.host)
  end

  def test_it_sets_user
    code = <<-CODE
    server_user "ubuntu"
    CODE
    runner = Prepper::Runner.new(code)
    assert_equal('ubuntu', runner.user)
  end

  def test_it_sets_port
    code = <<-CODE
    server_port 999
    CODE
    runner = Prepper::Runner.new(code)
    assert_equal(999, runner.port)
  end

  def test_it_sets_ssh_options
    code = <<-CODE
    ssh_options({ forward_agent: false })
    CODE
    runner = Prepper::Runner.new(code)
    assert_equal({forward_agent: false}, runner.instance_variable_get("@ssh_options"))
  end

  def test_server_hash
    code = <<-CODE
      server_host "test.com"
      server_port 999
      server_user "ubuntu"
      ssh_options({ forward_agent: false })
    CODE
    runner = Prepper::Runner.new(code)

    assert_equal(
      {
        hostname: 'test.com',
        user: 'ubuntu',
        port: 999,
        ssh_options: {forward_agent: false}
      },
      runner.server_hash
    )
  end

  def test_add_command_adds_a_package_with_a_command
    code = <<-CODE
      add_command "ls /"
    CODE
    runner = Prepper::Runner.new(code)
    refute_empty runner.packages
    assert_equal 1, runner.packages.size
    assert_equal 'base', runner.packages.first.name
    package_options = runner.packages.first.instance_variable_get("@opts")
    assert_equal 'root', package_options[:user]
    assert_equal '/', package_options[:within]
  end

  def test_add_command_can_override_user_and_within
    code = <<-CODE
      add_command "ls", user: "ubuntu", within: "/home/ubuntu"
    CODE
    runner = Prepper::Runner.new(code)
    package_options = runner.packages.first.instance_variable_get("@opts")
    assert_equal 'ubuntu', package_options[:user]
    assert_equal '/home/ubuntu', package_options[:within]
  end

  def test_package_registers_a_package
    code = <<-CODE
      package "list root" do
        add_command "ls /"
      end
    CODE
    runner = Prepper::Runner.new(code)
    assert_equal 1, runner.packages.size
    assert_equal "list root", runner.packages.first.name
    assert_equal 1, runner.packages.first.commands.size
    assert_equal runner, runner.packages.first.runner
  end
end
