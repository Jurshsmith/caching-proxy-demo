import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :caching_proxy_demo, CachingProxyDemo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "caching_proxy_demo_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :caching_proxy_demo, CachingProxyDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "653lQHyhCacOQJ/UkKQCg0fCWg0XtgxSo4+uyJTWy+P1HozfQyxM4QH3R5kWrtMp",
  server: false

# In test we don't send emails.
config :caching_proxy_demo, CachingProxyDemo.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :caching_proxy_demo, :cache, CachingProxyDemo.CacheMock
config :caching_proxy_demo, :marvel_http_client, CachingProxyDemo.Marvel.HTTPClientMock
config :caching_proxy_demo, :marvel_module, CachingProxyDemo.MarvelMock
