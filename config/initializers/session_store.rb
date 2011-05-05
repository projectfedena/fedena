# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fedena_session',
  :secret      => '93bd9933128611446605e1d410d003a6643d59c4494a56e538f4bb154284c14f5a56c8ed9e7b1b38593e6f557b1f28d763f0b0093e12ff515dea1107d2e1306b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
