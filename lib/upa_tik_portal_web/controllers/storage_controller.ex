defmodule UpaTikPortalWeb.StorageController do
  use UpaTikPortalWeb, :controller

  alias UpaTikPortal.Storage

  
  def view_image(conn, %{"key" => filename}) do
    case Storage.download(filename) do
      {:ok, %{body: content}} ->
        # Deteksi content type sederhana berdasarkan ekstensi
        content_type = 
          case Path.extname(filename) |> String.downcase() do
            ".png" -> "image/png"
            ".webp" -> "image/webp"
            _ -> "image/jpeg"
          end

        conn
        |> put_resp_content_type(content_type)
        |> send_resp(200, content)

      {:error, reason} ->
        IO.inspect(reason, label: "MinIO Download Error")
        send_resp(conn, 404, "Not Found")
    end
  end
end