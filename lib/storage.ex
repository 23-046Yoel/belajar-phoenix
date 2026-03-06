defmodule UpaTikPortal.Storage do

  alias ExAws.S3

  defp bucket_name do
    System.get_env("MINIO_BUCKET", "upa-tik-uploads")
  end

  def upload(src, dst) when is_binary(src) and is_binary(dst) do
    with {:ok, result} <-
      S3.Upload.stream_file(src)
      |> S3.upload(bucket_name(), dst)
      |> ExAws.request
    do
      {:ok, result}
    else
      error -> error
    end
  end

  def download(path) when is_binary(path) do
    with {:ok, result} <-
      S3.get_object(bucket_name(), path)
      |> ExAws.request
    do
      {:ok, result}
    else
      error ->
        IO.inspect(error)
        error
    end
  end

  def presigned_url(path) when is_binary(path) do
    with {:ok, result} <-
      S3
      |> ExAws.Config.new()
      |> ExAws.S3.presigned_url(:get, bucket_name(), path, [])
    do
      IO.inspect(result)
      {:ok, result}
    else
      error ->
        IO.inspect(error)
        error
    end
  end
end
  