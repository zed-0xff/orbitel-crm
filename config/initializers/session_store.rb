# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_config_session',
  :secret => '258a254e174ec1aac152de756b44eb568928e8f95b23e384d0a1acff4247e8b7ef5514c89c4d76869259650a53aa4550c56ebd3bae7a7759e2c0e4c64952464b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
