
require 'mixlib/shellout'
require 'helpers'

include Helpers

def run_command(cmd, **opts)
  shellout = Mixlib::ShellOut.new(cmd, opts)
  result = shellout.run_command
  if ENV['DEBUG_COMMANDS']
    puts "========================================"
    puts "ran command '#{cmd}' with opts '#{opts}'"
    puts "========================================"
    puts "stdout:\n#{result.stdout}"
    puts "========================================"
    puts "stderr:\n#{result.stderr}"
    puts "========================================"
  end
  result
end