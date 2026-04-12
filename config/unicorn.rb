rails_root = "/usr/local/app_root/haiban_sit_demo/webapp"
rails_env = 'production'

timeout 60
listen 3034, :tcp_nopush => true
worker_processes 4 # this should be >= nr_cpus
pid "#{rails_root}/shared/tmp/pids/unicorn.pid"
stderr_path "#{rails_root}/shared/log/unicorn.log"
stdout_path "#{rails_root}/shared/log/unicorn.log"
preload_app true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  old_pid =  "#{rails_root}/shared/tmp/pids/unicorn.pid.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
