# Default is to retry 25 times with exponential backoff. That's too much.
# Sidekiq.default_worker_options = { retry: 3 }
Sidekiq.default_job_options = { "retry" => true }

if Rails.env.development?
  # Sidekiq.default_worker_options[:backtrace] = true
end
