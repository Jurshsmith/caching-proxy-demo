ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(CachingProxyDemo.Repo, :manual)

Mox.defmock(CachingProxyDemo.CacheMock, for: CachingProxyDemo.Cache)
