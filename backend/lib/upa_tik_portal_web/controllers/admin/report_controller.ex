defmodule UpaTikPortalWeb.Admin.ReportController do
  use UpaTikPortalWeb, :controller

  alias UpaTikPortal.Requests
  alias UpaTikPortal.Keluhans

  def export_requests(conn, params) do
    requests = Requests.list_requests_filtered(params)
    format = Map.get(params, "format", "excel")

    if format == "csv" do
      headers = [
        "No",
        "NIM",
        "Nama Lengkap",
        "Tipe Pengajuan",
        "Email Kampus Baru",
        "Status",
        "Email Notifikasi",
        "Tanggal Pengajuan",
        "Catatan Admin"
      ]

      rows =
        Enum.with_index(requests, 1)
        |> Enum.map(fn {r, index} ->
          [
            index,
            r.nim,
            r.full_name,
            format_request_type(r.request_type),
            r.email_requested,
            format_status(r.status),
            r.notification_email,
            format_datetime(r.inserted_at),
            r.admin_notes || ""
          ]
        end)

      csv_content = to_csv(headers, rows)

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"laporan_pengajuan_#{current_date_string()}.csv\""
      )
      |> send_resp(200, csv_content)
    else
      # Excel SpreadsheetML
      headers = [
        "No",
        "NIM",
        "Nama Lengkap",
        "Tipe Pengajuan",
        "Email Kampus Baru",
        "Status",
        "Email Notifikasi",
        "Tanggal Pengajuan",
        "Catatan Admin"
      ]

      rows =
        Enum.with_index(requests, 1)
        |> Enum.map(fn {r, index} ->
          [
            %{value: index, type: "Number"},
            %{value: r.nim, type: "String"},
            %{value: r.full_name, type: "String"},
            %{value: format_request_type(r.request_type), type: "String"},
            %{value: r.email_requested, type: "String"},
            %{value: format_status(r.status), type: "String", status: r.status},
            %{value: r.notification_email, type: "String"},
            %{value: format_datetime(r.inserted_at), type: "String"},
            %{value: r.admin_notes || "", type: "String"}
          ]
        end)

      excel_xml =
        generate_spreadsheet_ml(
          "Laporan Pengajuan Akun",
          headers,
          rows,
          "#4F46E5",
          "Aktivasi/Reset Email"
        )

      conn
      |> put_resp_content_type("application/vnd.ms-excel")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"laporan_pengajuan_#{current_date_string()}.xls\""
      )
      |> send_resp(200, excel_xml)
    end
  end

  def export_keluhans(conn, params) do
    keluhans = Keluhans.list_keluhans_filtered(params)
    format = Map.get(params, "format", "excel")

    if format == "csv" do
      headers = [
        "No",
        "Nama Pelapor",
        "Email Pelapor",
        "Kategori Keluhan",
        "Subjek Keluhan",
        "Deskripsi",
        "Status",
        "Tanggal Laporan",
        "Catatan Admin"
      ]

      rows =
        Enum.with_index(keluhans, 1)
        |> Enum.map(fn {k, index} ->
          [
            index,
            k.user.name,
            k.user.email,
            format_category(k.category),
            k.subject,
            k.description,
            format_status(k.status),
            format_datetime(k.inserted_at),
            k.admin_notes || ""
          ]
        end)

      csv_content = to_csv(headers, rows)

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"laporan_keluhan_#{current_date_string()}.csv\""
      )
      |> send_resp(200, csv_content)
    else
      # Excel SpreadsheetML
      headers = [
        "No",
        "Nama Pelapor",
        "Email Pelapor",
        "Kategori Keluhan",
        "Subjek Keluhan",
        "Deskripsi",
        "Status",
        "Tanggal Laporan",
        "Catatan Admin"
      ]

      rows =
        Enum.with_index(keluhans, 1)
        |> Enum.map(fn {k, index} ->
          [
            %{value: index, type: "Number"},
            %{value: k.user.name, type: "String"},
            %{value: k.user.email, type: "String"},
            %{value: format_category(k.category), type: "String"},
            %{value: k.subject, type: "String"},
            %{value: k.description, type: "String"},
            %{value: format_status(k.status), type: "String", status: k.status},
            %{value: format_datetime(k.inserted_at), type: "String"},
            %{value: k.admin_notes || "", type: "String"}
          ]
        end)

      excel_xml =
        generate_spreadsheet_ml(
          "Laporan Keluhan Mahasiswa",
          headers,
          rows,
          "#E11D48",
          "Aduan Layanan TIK"
        )

      conn
      |> put_resp_content_type("application/vnd.ms-excel")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"laporan_keluhan_#{current_date_string()}.xls\""
      )
      |> send_resp(200, excel_xml)
    end
  end

  def export_all(conn, params) do
    requests = Requests.list_requests_filtered(params)
    keluhans = Keluhans.list_keluhans_filtered(params)

    # 1. Prepare Requests Worksheet Data
    req_headers = [
      "No",
      "NIM",
      "Nama Lengkap",
      "Tipe Pengajuan",
      "Email Kampus Baru",
      "Status",
      "Email Notifikasi",
      "Tanggal Pengajuan",
      "Catatan Admin"
    ]

    req_rows =
      Enum.with_index(requests, 1)
      |> Enum.map(fn {r, index} ->
        [
          %{value: index, type: "Number"},
          %{value: r.nim, type: "String"},
          %{value: r.full_name, type: "String"},
          %{value: format_request_type(r.request_type), type: "String"},
          %{value: r.email_requested, type: "String"},
          %{value: format_status(r.status), type: "String", status: r.status},
          %{value: r.notification_email, type: "String"},
          %{value: format_datetime(r.inserted_at), type: "String"},
          %{value: r.admin_notes || "", type: "String"}
        ]
      end)

    # 2. Prepare Keluhans Worksheet Data
    kel_headers = [
      "No",
      "Nama Pelapor",
      "Email Pelapor",
      "Kategori Keluhan",
      "Subjek Keluhan",
      "Deskripsi",
      "Status",
      "Tanggal Laporan",
      "Catatan Admin"
    ]

    kel_rows =
      Enum.with_index(keluhans, 1)
      |> Enum.map(fn {k, index} ->
        [
          %{value: index, type: "Number"},
          %{value: k.user.name, type: "String"},
          %{value: k.user.email, type: "String"},
          %{value: format_category(k.category), type: "String"},
          %{value: k.subject, type: "String"},
          %{value: k.description, type: "String"},
          %{value: format_status(k.status), type: "String", status: k.status},
          %{value: format_datetime(k.inserted_at), type: "String"},
          %{value: k.admin_notes || "", type: "String"}
        ]
      end)

    excel_xml = generate_consolidated_spreadsheet_ml(req_headers, req_rows, kel_headers, kel_rows)

    conn
    |> put_resp_content_type("application/vnd.ms-excel")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=\"laporan_konsolidasi_#{current_date_string()}.xls\""
    )
    |> send_resp(200, excel_xml)
  end

  # Helpers
  defp format_request_type("aktivasi"), do: "Aktivasi Akun"
  defp format_request_type("reset"), do: "Reset Password"
  defp format_request_type(t), do: t

  defp format_status("pending"), do: "Menunggu"
  defp format_status("baru"), do: "Baru"
  defp format_status("diproses"), do: "Diproses"
  defp format_status("disetujui"), do: "Disetujui"
  defp format_status("selesai"), do: "Selesai"
  defp format_status("ditolak"), do: "Ditolak"
  defp format_status(s), do: s

  defp format_category("sso_gmail"), do: "SSO & Akun Gmail"
  defp format_category("internet_wifi"), do: "Koneksi Wi-Fi & Internet"
  defp format_category("portal_sia"), do: "Portal SIA / Akademik"
  defp format_category("hardware_fasilitas"), do: "Fasilitas Lab / Hardware"
  defp format_category("lainnya"), do: "Lainnya / Umum"
  defp format_category(c), do: c

  defp format_datetime(nil), do: ""

  defp format_datetime(dt) do
    Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S")
  end

  defp current_date_string do
    Date.utc_today() |> Date.to_string()
  end

  # CSV Generator Helper
  defp to_csv(headers, rows) do
    csv_headers = Enum.map_join(headers, ",", &escape_csv/1)

    csv_rows =
      Enum.map_join(rows, "\n", fn row ->
        Enum.map_join(row, ",", &escape_csv/1)
      end)

    csv_headers <> "\n" <> csv_rows
  end

  defp escape_csv(val) when is_binary(val) do
    if String.contains?(val, [",", "\"", "\n", "\r"]) do
      "\"" <> String.replace(val, "\"", "\"\"") <> "\""
    else
      val
    end
  end

  defp escape_csv(nil), do: ""
  defp escape_csv(val), do: to_string(val)

  # Excel SpreadsheetML (XML) Generator Helper
  defp generate_spreadsheet_ml(title, headers, rows, theme_color, _subtitle_type) do
    col_count = length(headers)
    style_header_bg = theme_color

    row_xmls =
      rows
      |> Enum.with_index(1)
      |> Enum.map(fn {row_data, idx} ->
        bg_style = if rem(idx, 2) == 0, do: "RowEven", else: "RowOdd"

        cell_xmls =
          row_data
          |> Enum.map(fn
            %{value: val, type: type, status: status} ->
              status_style =
                case status do
                  s when s in ["pending", "baru"] -> "StatusPending"
                  s when s in ["disetujui", "selesai"] -> "StatusDisetujui"
                  s when s in ["ditolak"] -> "StatusDitolak"
                  "diproses" -> "StatusDiproses"
                  _ -> bg_style
                end

              """
              <Cell ss:StyleID="#{status_style}"><Data ss:Type="#{type}">#{escape_xml(val)}</Data></Cell>
              """

            %{value: val, type: type} ->
              """
              <Cell ss:StyleID="#{bg_style}"><Data ss:Type="#{type}">#{escape_xml(val)}</Data></Cell>
              """

            val ->
              """
              <Cell ss:StyleID="#{bg_style}"><Data ss:Type="String">#{escape_xml(val)}</Data></Cell>
              """
          end)
          |> Enum.join("")

        """
        <Row ss:Height="22">
          #{cell_xmls}
        </Row>
        """
      end)
      |> Enum.join("")

    header_cells =
      headers
      |> Enum.map(fn h ->
        """
        <Cell ss:StyleID="Header"><Data ss:Type="String">#{escape_xml(h)}</Data></Cell>
        """
      end)
      |> Enum.join("")

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <?mso-application progid="Excel.Sheet"?>
    <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
     xmlns:o="urn:schemas-microsoft-com:office:office"
     xmlns:x="urn:schemas-microsoft-com:office:excel"
     xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
     xmlns:html="http://www.w3.org/TR/REC-html40">
      <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
        <Author>UPA TIK Portal</Author>
        <Created>#{DateTime.utc_now() |> DateTime.to_iso8601()}</Created>
      </DocumentProperties>
      <Styles>
        <Style ss:ID="Default" ss:Name="Normal">
          <Alignment ss:Vertical="Center"/>
          <Borders/>
          <Font ss:FontName="Calibri" x:CharSet="1" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
          <Interior/>
          <NumberFormat/>
          <Protection/>
        </Style>
        <Style ss:ID="Title">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="16" ss:Bold="1" ss:Color="#1E3A8A"/>
        </Style>
        <Style ss:ID="Subtitle">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Italic="1" ss:Color="#4B5563"/>
        </Style>
        <Style ss:ID="Header">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
          </Borders>
          <Font ss:FontName="Calibri" ss:Size="11" ss:Bold="1" ss:Color="#FFFFFF"/>
          <Interior ss:Color="#{style_header_bg}" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="RowEven">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#1F2937"/>
          <Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="RowOdd">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#1F2937"/>
          <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusPending">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#D97706" ss:Bold="1"/>
          <Interior ss:Color="#FEF3C7" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusDiproses">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#D97706" ss:Bold="1"/>
          <Interior ss:Color="#FEF3C7" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusDisetujui">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#059669" ss:Bold="1"/>
          <Interior ss:Color="#D1FAE5" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusDitolak">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#DC2626" ss:Bold="1"/>
          <Interior ss:Color="#FEE2E2" ss:Pattern="Solid"/>
        </Style>
      </Styles>
      <Worksheet ss:Name="Laporan">
        <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="120" ss:DefaultRowHeight="20">
          <Column ss:Width="40"/> <!-- No -->
          <Column ss:Width="100"/> <!-- NIM or Name -->
          <Column ss:Width="150"/> <!-- Full Name -->
          <Column ss:Width="120"/> <!-- Type or Category -->
          <Column ss:Width="180"/> <!-- Email or Subject -->
          <Column ss:Width="100"/> <!-- Status -->
          <Column ss:Width="180"/> <!-- Notification Email or Desc -->
          <Column ss:Width="130"/> <!-- Date -->
          <Column ss:Width="200"/> <!-- Notes -->

          <!-- Title Block -->
          <Row ss:Height="30">
            <Cell ss:MergeAcross="#{col_count - 1}" ss:StyleID="Title">
              <Data ss:Type="String">#{title}</Data>
            </Cell>
          </Row>
          <Row ss:Height="20">
            <Cell ss:MergeAcross="#{col_count - 1}" ss:StyleID="Subtitle">
              <Data ss:Type="String">Dihasilkan oleh Sistem Portal UPA TIK pada #{DateTime.utc_now() |> DateTime.add(7 * 3600, :second) |> Calendar.strftime("%Y-%m-%d %H:%M:%S")} WIB</Data>
            </Cell>
          </Row>
          <Row ss:Index="4" ss:Height="24">
            #{header_cells}
          </Row>

          #{row_xmls}
        </Table>
        <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
          <PageLayoutZoom>0</PageLayoutZoom>
          <Selected/>
          <ProtectObjects>False</ProtectObjects>
          <ProtectScenarios>False</ProtectScenarios>
        </WorksheetOptions>
      </Worksheet>
    </Workbook>
    """
  end

  defp generate_consolidated_spreadsheet_ml(req_headers, req_rows, kel_headers, kel_rows) do
    req_row_xmls = generate_worksheet_rows_xml(req_rows)
    req_header_cells = generate_worksheet_headers_xml(req_headers, "HeaderReq")

    kel_row_xmls = generate_worksheet_rows_xml(kel_rows)
    kel_header_cells = generate_worksheet_headers_xml(kel_headers, "HeaderKel")

    req_col_count = length(req_headers)
    kel_col_count = length(kel_headers)

    formatted_time =
      DateTime.utc_now()
      |> DateTime.add(7 * 3600, :second)
      |> Calendar.strftime("%Y-%m-%d %H:%M:%S")

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <?mso-application progid="Excel.Sheet"?>
    <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
     xmlns:o="urn:schemas-microsoft-com:office:office"
     xmlns:x="urn:schemas-microsoft-com:office:excel"
     xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
     xmlns:html="http://www.w3.org/TR/REC-html40">
      <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
        <Author>UPA TIK Portal</Author>
        <Created>#{DateTime.utc_now() |> DateTime.to_iso8601()}</Created>
      </DocumentProperties>
      <Styles>
        <Style ss:ID="Default" ss:Name="Normal">
          <Alignment ss:Vertical="Center"/>
          <Borders/>
          <Font ss:FontName="Calibri" x:CharSet="1" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
          <Interior/>
          <NumberFormat/>
          <Protection/>
        </Style>
        <Style ss:ID="Title">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="16" ss:Bold="1" ss:Color="#1E3A8A"/>
        </Style>
        <Style ss:ID="Subtitle">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Italic="1" ss:Color="#4B5563"/>
        </Style>
        <Style ss:ID="HeaderReq">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
          </Borders>
          <Font ss:FontName="Calibri" ss:Size="11" ss:Bold="1" ss:Color="#FFFFFF"/>
          <Interior ss:Color="#4F46E5" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="HeaderKel">
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#D1D5DB"/>
          </Borders>
          <Font ss:FontName="Calibri" ss:Size="11" ss:Bold="1" ss:Color="#FFFFFF"/>
          <Interior ss:Color="#E11D48" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="RowEven">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#1F2937"/>
          <Interior ss:Color="#F8FAFC" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="RowOdd">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#1F2937"/>
          <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusPending">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#D97706" ss:Bold="1"/>
          <Interior ss:Color="#FEF3C7" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusDiproses">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#D97706" ss:Bold="1"/>
          <Interior ss:Color="#FEF3C7" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusDisetujui">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#059669" ss:Bold="1"/>
          <Interior ss:Color="#D1FAE5" ss:Pattern="Solid"/>
        </Style>
        <Style ss:ID="StatusDitolak">
          <Borders>
            <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
            <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/>
          </Borders>
          <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>
          <Font ss:FontName="Calibri" ss:Size="10" ss:Color="#DC2626" ss:Bold="1"/>
          <Interior ss:Color="#FEE2E2" ss:Pattern="Solid"/>
        </Style>
      </Styles>
      <Worksheet ss:Name="Pengajuan Akun">
        <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="120" ss:DefaultRowHeight="20">
          <Column ss:Width="40"/> <!-- No -->
          <Column ss:Width="100"/> <!-- NIM -->
          <Column ss:Width="150"/> <!-- Nama Lengkap -->
          <Column ss:Width="120"/> <!-- Tipe Pengajuan -->
          <Column ss:Width="180"/> <!-- Email Kampus Baru -->
          <Column ss:Width="100"/> <!-- Status -->
          <Column ss:Width="180"/> <!-- Email Notifikasi -->
          <Column ss:Width="130"/> <!-- Tanggal -->
          <Column ss:Width="200"/> <!-- Catatan Admin -->

          <!-- Title Block -->
          <Row ss:Height="30">
            <Cell ss:MergeAcross="#{req_col_count - 1}" ss:StyleID="Title">
              <Data ss:Type="String">Laporan Pengajuan Akun</Data>
            </Cell>
          </Row>
          <Row ss:Height="20">
            <Cell ss:MergeAcross="#{req_col_count - 1}" ss:StyleID="Subtitle">
              <Data ss:Type="String">Dihasilkan oleh Sistem Portal UPA TIK pada #{formatted_time} WIB</Data>
            </Cell>
          </Row>
          <Row ss:Index="4" ss:Height="24">
            #{req_header_cells}
          </Row>

          #{req_row_xmls}
        </Table>
        <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
          <PageLayoutZoom>0</PageLayoutZoom>
          <ProtectObjects>False</ProtectObjects>
          <ProtectScenarios>False</ProtectScenarios>
        </WorksheetOptions>
      </Worksheet>

      <Worksheet ss:Name="Keluhan Mahasiswa">
        <Table x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth="120" ss:DefaultRowHeight="20">
          <Column ss:Width="40"/> <!-- No -->
          <Column ss:Width="150"/> <!-- Nama Pelapor -->
          <Column ss:Width="150"/> <!-- Email Pelapor -->
          <Column ss:Width="150"/> <!-- Kategori -->
          <Column ss:Width="180"/> <!-- Subjek -->
          <Column ss:Width="200"/> <!-- Deskripsi -->
          <Column ss:Width="100"/> <!-- Status -->
          <Column ss:Width="130"/> <!-- Tanggal -->
          <Column ss:Width="200"/> <!-- Catatan Admin -->

          <!-- Title Block -->
          <Row ss:Height="30">
            <Cell ss:MergeAcross="#{kel_col_count - 1}" ss:StyleID="Title">
              <Data ss:Type="String">Laporan Keluhan Mahasiswa</Data>
            </Cell>
          </Row>
          <Row ss:Height="20">
            <Cell ss:MergeAcross="#{kel_col_count - 1}" ss:StyleID="Subtitle">
              <Data ss:Type="String">Dihasilkan oleh Sistem Portal UPA TIK pada #{formatted_time} WIB</Data>
            </Cell>
          </Row>
          <Row ss:Index="4" ss:Height="24">
            #{kel_header_cells}
          </Row>

          #{kel_row_xmls}
        </Table>
        <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
          <PageLayoutZoom>0</PageLayoutZoom>
          <ProtectObjects>False</ProtectObjects>
          <ProtectScenarios>False</ProtectScenarios>
        </WorksheetOptions>
      </Worksheet>
    </Workbook>
    """
  end

  defp generate_worksheet_rows_xml(rows) do
    rows
    |> Enum.with_index(1)
    |> Enum.map(fn {row_data, idx} ->
      bg_style = if rem(idx, 2) == 0, do: "RowEven", else: "RowOdd"

      cell_xmls =
        row_data
        |> Enum.map(fn
          %{value: val, type: type, status: status} ->
            status_style =
              case status do
                s when s in ["pending", "baru"] -> "StatusPending"
                s when s in ["disetujui", "selesai"] -> "StatusDisetujui"
                s when s in ["ditolak"] -> "StatusDitolak"
                "diproses" -> "StatusDiproses"
                _ -> bg_style
              end

            """
            <Cell ss:StyleID="#{status_style}"><Data ss:Type="#{type}">#{escape_xml(val)}</Data></Cell>
            """

          %{value: val, type: type} ->
            """
            <Cell ss:StyleID="#{bg_style}"><Data ss:Type="#{type}">#{escape_xml(val)}</Data></Cell>
            """

          val ->
            """
            <Cell ss:StyleID="#{bg_style}"><Data ss:Type="String">#{escape_xml(val)}</Data></Cell>
            """
        end)
        |> Enum.join("")

      """
      <Row ss:Height="22">
        #{cell_xmls}
      </Row>
      """
    end)
    |> Enum.join("")
  end

  defp generate_worksheet_headers_xml(headers, style_id) do
    headers
    |> Enum.map(fn h ->
      """
      <Cell ss:StyleID="#{style_id}"><Data ss:Type="String">#{escape_xml(h)}</Data></Cell>
      """
    end)
    |> Enum.join("")
  end

  defp escape_xml(val) when is_binary(val) do
    val
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end

  defp escape_xml(val), do: to_string(val)
end
