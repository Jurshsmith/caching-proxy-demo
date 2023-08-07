defmodule CachingProxyDemo.Repo.Migrations.CreateHttpRequests do
  use Ecto.Migration

  def change do
    create table(:http_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :method, :string, null: false
      add :url, :string, null: false
      add :status, :string, null: false

      timestamps(updated_at: false)
    end

    create index(:http_requests, [:method, :url])
  end
end
