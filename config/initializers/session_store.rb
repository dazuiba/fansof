# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_fansof_session',
  :secret      => 'b66d67aa927eb811e56651f61aed5828daba30955468bd8341c99acb747c07412b37d1b3bf14ea1d162b5a576b8448bfac2f55c3ef42cfd6f6a8459bb02744b5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
