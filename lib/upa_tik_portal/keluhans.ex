defmodule UpaTikPortal.Keluhans do
  @moduledoc """
  The Keluhans context - handles user complaints/feedback.
  """

  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Keluhans.Keluhan

  @doc "Create a new keluhan submitted by a user."
  def create_keluhan(user_id, attrs) do
    %Keluhan{}
    |> Keluhan.changeset(Map.put(attrs, "user_id", user_id))
    |> Repo.insert()
  end

  @doc "List all keluhans (for admin), ordered by newest first."
  def list_keluhans do
    Keluhan
    |> order_by([k], desc: k.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc "List keluhans submitted by a specific user."
  def list_keluhans_by_user(user_id) do
    Keluhan
    |> where([k], k.user_id == ^user_id)
    |> order_by([k], desc: k.inserted_at)
    |> Repo.all()
  end

  @doc "Get a single keluhan by id."
  def get_keluhan!(id), do: Repo.get!(Keluhan, id) |> Repo.preload(:user)

  @doc "Admin updates the status of a keluhan."
  def update_keluhan_status(keluhan, attrs) do    
    keluhan
    |> Keluhan.status_changeset(attrs)
    |> Repo.update()
  end

  @doc "Count keluhans grouped by status (for dashboard stats)."
  def stats do
    Keluhan
    |> group_by([k], k.status)
    |> select([k], {k.status, count(k.id)})
    |> Repo.all()
    |> Map.new()
  end
end 



