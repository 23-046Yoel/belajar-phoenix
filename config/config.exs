# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :upa_tik_portal,
  ecto_repos: [UpaTikPortal.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true]

# Configure the endpoint
config :upa_tik_portal, UpaTikPortalWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: UpaTikPortalWeb.ErrorHTML, json: UpaTikPortalWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: UpaTikPortal.PubSub,
  live_view: [signing_salt: "emOW/0yF"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  upa_tik_portal: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  upa_tik_portal: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  base_path: "/auth",
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

# Google OAuth configuration will be handled in runtime.exs

# Configure Swoosh mailer
config :upa_tik_portal, UpaTikPortal.Mailer, adapter: Swoosh.Adapters.Local

# Configure Waffle for file uploads (KTM photo)
config :waffle,
  storage: Waffle.Storage.Local,
  storage_dir: "priv/static/uploads"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
