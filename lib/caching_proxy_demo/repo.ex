defmodule CachingProxyDemo.Repo do
  use Ecto.Repo,
    otp_app: :caching_proxy_demo,
    adapter: Ecto.Adapters.Postgres
end
