defmodule UpaTikPortal.Keluhans do
  @moduledoc """
  The Keluhans context - handles user complaints/feedback.
  """

  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Keluhans.Keluhan
  alias UpaTikPortal.Keluhans.Message

  @pubsub UpaTikPortal.PubSub

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
    |> preload(messages: [:user])
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

  def subscribe(keluhan_id) do
    Phoenix.PubSub.subscribe(@pubsub, "keluhan_#{keluhan_id}")
  end

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(@pubsub, "keluhan_#{message.keluhan_id}", {event, message})
    {:ok, message}
  end

  @doc "Get a single keluhan by id, preloaded with user and messages."
  def get_keluhan_with_messages!(id) do
    Keluhan
    |> Repo.get!(id)
    |> Repo.preload(:user)
    |> Repo.preload(messages: [:user])
  end

  @doc "Create a new message in a keluhan."
  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, msg} ->
        # Preload user so the UI can display sender info
        msg = Repo.preload(msg, :user)
        broadcast({:ok, msg}, :new_message)

      error ->
        error
    end
  end

  @doc """
  Mengambil statistik jumlah keluhan per kategori.
  """
  def get_category_stats do
    get_category_stats_filtered(%{})
  end

  @doc """
  Mengambil statistik jumlah keluhan per kategori terfilter tanggal.
  """
  def get_category_stats_filtered(filters \\ %{}) do
    filters = normalize_filters(filters)
    query = from(k in Keluhan)
    query = filter_date_range(query, filters.start_date, filters.end_date)

    query
    |> group_by([k], k.category)
    |> select([k], {k.category, count(k.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc "Statistik keluhan terfilter tanggal"
  def stats_filtered(filters \\ %{}) do
    filters = normalize_filters(filters)
    query = from(k in Keluhan)
    query = filter_date_range(query, filters.start_date, filters.end_date)

    query
    |> group_by([k], k.status)
    |> select([k], {k.status, count(k.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc "Daftar keluhan terfilter"
  def list_keluhans_filtered(filters \\ %{}) do
    filters = normalize_filters(filters)

    query =
      from k in Keluhan,
        as: :keluhan,
        join: u in assoc(k, :user),
        as: :user,
        preload: [user: u],
        order_by: [desc: k.inserted_at]

    query
    |> filter_status(filters.status)
    |> filter_category(filters.category)
    |> filter_date_range(filters.start_date, filters.end_date)
    |> filter_search(filters.search)
    |> Repo.all()
  end

  defp normalize_filters(filters) do
    %{
      status: Map.get(filters, "status") || Map.get(filters, :status),
      category: Map.get(filters, "category") || Map.get(filters, :category),
      start_date: Map.get(filters, "start_date") || Map.get(filters, :start_date),
      end_date: Map.get(filters, "end_date") || Map.get(filters, :end_date),
      search: Map.get(filters, "search") || Map.get(filters, :search)
    }
  end

  defp filter_status(query, nil), do: query
  defp filter_status(query, ""), do: query
  defp filter_status(query, "all"), do: query
  defp filter_status(query, status), do: from(k in query, where: k.status == ^status)

  defp filter_category(query, nil), do: query
  defp filter_category(query, ""), do: query
  defp filter_category(query, "all"), do: query
  defp filter_category(query, category), do: from(k in query, where: k.category == ^category)

  defp filter_date_range(query, start_date, end_date) do
    query
    |> filter_start_date(start_date)
    |> filter_end_date(end_date)
  end

  defp filter_start_date(query, nil), do: query
  defp filter_start_date(query, ""), do: query

  defp filter_start_date(query, start_date) when is_binary(start_date) do
    case Date.from_iso8601(start_date) do
      {:ok, date} ->
        naive_dt = NaiveDateTime.new!(date, ~T[00:00:00])
        dt = DateTime.from_naive!(naive_dt, "Etc/UTC")
        from(k in query, where: k.inserted_at >= ^dt)

      _ ->
        query
    end
  end

  defp filter_start_date(query, _), do: query

  defp filter_end_date(query, nil), do: query
  defp filter_end_date(query, ""), do: query

  defp filter_end_date(query, end_date) when is_binary(end_date) do
    case Date.from_iso8601(end_date) do
      {:ok, date} ->
        naive_dt = NaiveDateTime.new!(date, ~T[23:59:59])
        dt = DateTime.from_naive!(naive_dt, "Etc/UTC")
        from(k in query, where: k.inserted_at <= ^dt)

      _ ->
        query
    end
  end

  defp filter_end_date(query, _), do: query

  defp filter_search(query, nil), do: query
  defp filter_search(query, ""), do: query

  defp filter_search(query, search) do
    search_term = "%#{String.downcase(search)}%"

    from [keluhan: k, user: u] in query,
      where:
        ilike(k.subject, ^search_term) or ilike(k.description, ^search_term) or
          ilike(u.name, ^search_term) or ilike(u.email, ^search_term)
  end
end
