defmodule UpaTikPortal.Storage do
  alias ExAws.S3

  defp bucket_name do
    System.get_env("MINIO_BUCKET", "upa-tik-uploads")
  end

  # Build explicit ExAws config from env vars to avoid partition lookup errors
  # when using S3-compatible services (Supabase Storage, MinIO, R2, etc.)
  defp s3_config do
    host = System.get_env("MINIO_HOST", "127.0.0.1")
    port = String.to_integer(System.get_env("MINIO_PORT", "9000"))
    scheme = if port == 443, do: "https://", else: "http://"
    region = System.get_env("MINIO_REGION") || (if port == 443, do: "ap-southeast-1", else: "us-east-1")

    ExAws.Config.new(:s3,
      host: host,
      port: port,
      scheme: scheme,
      region: region,
      access_key_id: System.get_env("MINIO_ACCESS_KEY"),
      secret_access_key: System.get_env("MINIO_SECRET_KEY")
    )
  end

  def upload(src, dst) when is_binary(src) and is_binary(dst) do
    with {:ok, result} <-
           S3.Upload.stream_file(src)
           |> S3.upload(bucket_name(), dst)
           |> ExAws.request() do
      {:ok, result}
    else
      error -> error
    end
  end

  def download(path) when is_binary(path) do
    with {:ok, result} <-
           S3.get_object(bucket_name(), path)
           |> ExAws.request() do
      {:ok, result}
    else
      error ->
        IO.inspect(error)
        error
    end
  end

  def presigned_url(path) when is_binary(path) do
    with {:ok, result} <-
           ExAws.S3.presigned_url(s3_config(), :get, bucket_name(), path, []) do
      {:ok, result}
    else
      error ->
        IO.inspect(error)
        error
    end
  end
end
