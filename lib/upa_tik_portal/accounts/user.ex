defmodule UpaTikPortal.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :name, :string
    field :email, :string
    field :role, :string, default: "mahasiswa"
    field :google_uid, :string

    has_many :email_requests, UpaTikPortal.Requests.EmailRequest

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :role, :google_uid])
    |> validate_required([:name, :email])
    |> validate_inclusion(:role, ["mahasiswa", "admin"])
    |> unique_constraint(:email)
    |> unique_constraint(:google_uid)
  end
end
