defmodule UpaTikPortal.Requests do
  @moduledoc """
  Context untuk manajemen pengajuan aktivasi/reset email kampus.
  """
  import Ecto.Query, warn: false
  alias UpaTikPortal.Repo
  alias UpaTikPortal.Requests.EmailRequest
  alias UpaTikPortal.Mailer
  alias UpaTikPortal.Emails

  @doc "Daftar semua pengajuan, diurutkan terbaru dulu"
  def list_requests do
    Repo.all(from r in EmailRequest, order_by: [desc: r.inserted_at], preload: [:user])
  end

  @doc "Daftar pengajuan milik user tertentu"
  def list_requests_by_user(user_id) do
    Repo.all(
      from r in EmailRequest,
        where: r.user_id == ^user_id,
        order_by: [desc: r.inserted_at]
    )
  end

  @doc "Dapatkan satu pengajuan (404 jika tidak ada)"
  def get_request!(id), do: Repo.get!(EmailRequest, id) |> Repo.preload(:user)

  @doc "Buat pengajuan baru"
  def create_request(user_id, attrs) do
    %EmailRequest{user_id: user_id}
    |> EmailRequest.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Update status pengajuan (Disetujui / Ditolak)"
  def update_status(%EmailRequest{} = request, status, notes \\ nil) do
    request
    |> EmailRequest.status_changeset(%{status: status, admin_notes: notes})
    |> Repo.update()
  end

  @doc "Simpan catatan admin saja"
  def update_admin_notes(%EmailRequest{} = request, notes) do
    request
    |> EmailRequest.notes_changeset(%{admin_notes: notes})
    |> Repo.update()
  end

  @doc "Hapus pengajuan"
  def delete_request(%EmailRequest{} = request) do
    Repo.delete(request)
  end

  @doc """
  Generate OTP 6-digit (atau gunakan custom), simpan ke DB, dan kirim email ke mahasiswa.
  """
  def send_otp(%EmailRequest{} = request, custom_otp \\ nil) do
    otp = custom_otp || :crypto.strong_rand_bytes(3) |> Base.encode16() |> String.slice(0, 6)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    with {:ok, updated_request} <-
           request
           |> EmailRequest.otp_changeset(%{otp_code: otp, otp_sent_at: now})
           |> Repo.update(),
         {:ok, _email} <- Emails.otp_email(updated_request) |> Mailer.deliver() do
      {:ok, updated_request}
    end
  end

  @doc "Statistik: jumlah per status"
  def stats do
    Repo.all(
      from r in EmailRequest,
        group_by: r.status,
        select: {r.status, count(r.id)}
    )
    |> Enum.into(%{})
  end

  @doc "Statistik: jumlah per status terfilter tanggal"
  def stats_filtered(filters \\ %{}) do
    filters = normalize_filters(filters)
    query = from(r in EmailRequest)
    query = filter_date_range(query, filters.start_date, filters.end_date)

    Repo.all(
      from r in query,
        group_by: r.status,
        select: {r.status, count(r.id)}
    )
    |> Enum.into(%{})
  end

  @doc "Daftar pengajuan dengan filter"
  def list_requests_filtered(filters \\ %{}) do
    filters = normalize_filters(filters)

    query =
      from r in EmailRequest,
        as: :request,
        join: u in assoc(r, :user),
        as: :user,
        preload: [user: u],
        order_by: [desc: r.inserted_at]

    query
    |> filter_status(filters.status)
    |> filter_date_range(filters.start_date, filters.end_date)
    |> filter_search(filters.search)
    |> Repo.all()
  end

  @doc """
  Mengambil statistik pengajuan bulanan untuk 6 bulan terakhir (Aktivasi vs Reset).
  """
  def get_monthly_stats do
    get_monthly_stats_filtered(%{})
  end

  @doc """
  Mengambil statistik pengajuan bulanan terfilter tanggal.
  """
  def get_monthly_stats_filtered(filters \\ %{}) do
    filters = normalize_filters(filters)
    now = Date.utc_today()

    months =
      for i <- 5..0//-1 do
        Date.add(now, -i * 30) |> Calendar.strftime("%Y-%m")
      end
      |> Enum.uniq()

    six_months_ago = DateTime.utc_now() |> DateTime.add(-6 * 30, :day)

    query = from r in EmailRequest, where: r.inserted_at >= ^six_months_ago
    query = filter_date_range(query, filters.start_date, filters.end_date)

    db_data =
      Repo.all(
        from r in query,
          select: {fragment("to_char(?, 'YYYY-MM')", r.inserted_at), r.request_type, count(r.id)},
          group_by: [fragment("to_char(?, 'YYYY-MM')", r.inserted_at), r.request_type]
      )

    data_map =
      Enum.reduce(db_data, %{}, fn {month, type, count}, acc ->
        Map.update(acc, month, %{type => count}, &Map.put(&1, type, count))
      end)

    Enum.map(months, fn m ->
      month_data = Map.get(data_map, m, %{})

      %{
        month: m,
        aktivasi: Map.get(month_data, "aktivasi", 0),
        reset: Map.get(month_data, "reset", 0)
      }
    end)
  end

  defp normalize_filters(filters) do
    %{
      status: Map.get(filters, "status") || Map.get(filters, :status),
      start_date: Map.get(filters, "start_date") || Map.get(filters, :start_date),
      end_date: Map.get(filters, "end_date") || Map.get(filters, :end_date),
      search: Map.get(filters, "search") || Map.get(filters, :search)
    }
  end

  defp filter_status(query, nil), do: query
  defp filter_status(query, ""), do: query
  defp filter_status(query, "all"), do: query
  defp filter_status(query, status), do: from(r in query, where: r.status == ^status)

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
        from(r in query, where: r.inserted_at >= ^dt)

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
        from(r in query, where: r.inserted_at <= ^dt)

      _ ->
        query
    end
  end

  defp filter_end_date(query, _), do: query

  defp filter_search(query, nil), do: query
  defp filter_search(query, ""), do: query

  defp filter_search(query, search) do
    search_term = "%#{String.downcase(search)}%"

    from [request: r, user: u] in query,
      where:
        ilike(r.nim, ^search_term) or ilike(r.full_name, ^search_term) or
          ilike(u.name, ^search_term)
  end
end
