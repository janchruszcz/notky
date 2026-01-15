# frozen_string_literal: true

module Rack
  class Attack
    ### Configure Cache ###

    # If you don't want to use Rails.cache (recommended), configure a separate cache
    # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    ### Throttle Spammy Clients ###

    # Throttle all requests by IP (60rpm)
    throttle('req/ip', limit: 300, period: 5.minutes) do |req|
      req.ip unless req.path.start_with?('/assets')
    end

    ### Prevent Brute-Force Login Attacks ###

    # Throttle POST requests to /users/sign_in by IP address
    throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if req.path == '/users/sign_in' && req.post?
    end

    # Throttle POST requests to /users/sign_in by email param
    throttle('logins/email', limit: 5, period: 20.seconds) do |req|
      if req.path == '/users/sign_in' && req.post?
        # Normalize email: downcase and strip
        req.params.dig('user', 'email')&.downcase&.strip
      end
    end

    ### Prevent Password Reset Attacks ###

    throttle('password_resets/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if req.path == '/users/password' && req.post?
    end

    ### Prevent Registration Spam ###

    throttle('registrations/ip', limit: 3, period: 60.seconds) do |req|
      req.ip if req.path == '/users' && req.post?
    end

    ### Block Suspicious Requests ###

    # Block requests trying to access common attack vectors
    blocklist('block bad paths') do |req|
      req.path.include?('/wp-admin') ||
        req.path.include?('/wp-login') ||
        req.path.include?('.php') ||
        req.path.include?('/xmlrpc') ||
        req.path.include?('/.env') ||
        req.path.include?('/.git')
    end

    ### Custom Blocklist Response ###

    self.blocklisted_responder = lambda do |_request|
      [403, { 'Content-Type' => 'text/plain' }, ["Forbidden\n"]]
    end

    self.throttled_responder = lambda do |request|
      match_data = request.env['rack.attack.match_data']
      now = match_data[:epoch_time]
      retry_after = match_data[:period] - (now % match_data[:period])

      [
        429,
        {
          'Content-Type' => 'text/plain',
          'Retry-After' => retry_after.to_s
        },
        ["Rate limit exceeded. Retry in #{retry_after} seconds.\n"]
      ]
    end
  end
end

# Log blocked and throttled requests in production
ActiveSupport::Notifications.subscribe('blocklist.rack_attack') do |_name, _start, _finish, _id, payload|
  Rails.logger.warn "[Rack::Attack] Blocked #{payload[:request].ip} - #{payload[:request].path}"
end

ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |_name, _start, _finish, _id, payload|
  Rails.logger.warn "[Rack::Attack] Throttled #{payload[:request].ip} - #{payload[:request].path}"
end
