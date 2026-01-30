defmodule TableauEexExtension do
  @moduledoc """
  Tableau extension for rendering EEx templates to static files.

  Processes `.eex` files from the configured directory and renders them
  to the output directory with the `.eex` extension stripped.

  ## Configuration

  ```elixir
  config :tableau, TableauEexExtension,
    enabled: true,
    dir: "_eex"
  ```

  ## Usage

  Create EEx template files in the configured directory:

  ```eex
  # _eex/humans.txt.eex
  /* TEAM */
  Author: <%= @config.author %>
  Site: <%= @config.url %>

  /* SITE */
  Last update: <%= Date.to_iso8601(Date.utc_today()) %>
  ```

  ```eex
  # _eex/robots.txt.eex
  User-agent: *
  <%= if @config.env == :prod do %>
  Allow: /
  <% else %>
  Disallow: /
  <% end %>
  Sitemap: <%= @config.url %>/sitemap.xml
  ```

  The extension renders templates to the output directory, stripping `.eex`.
  Templates have access to `@token` (Tableau token) and `@config` (site config).

  ## Notes

  - Runs at priority 400, after sitemap generation
  - Generated files are not part of Tableau's page graph and will not appear in sitemaps
  """

  use Tableau.Extension, key: :eex, priority: 400

  require Logger

  @defaults %{enabled: false, dir: "_eex"}

  @impl Tableau.Extension
  def config(config) when is_list(config), do: {:ok, Map.merge(@defaults, Map.new(config))}
  def config(config) when is_map(config), do: {:ok, Map.merge(@defaults, config)}

  @impl Tableau.Extension
  def post_write(token) do
    render_eex_files(token, token.extensions.eex.config)
  rescue
    e ->
      Logger.error(Exception.format(:error, e, __STACKTRACE__))
      {:error, :fail}
  end

  defp render_eex_files(token, config) do
    config.dir
    |> Path.join("**/*.eex")
    |> Path.wildcard()
    |> Enum.each(&render_output(&1, token, config))

    {:ok, token}
  end

  defp render_output(path, token, config) do
    content = render_template(path, token)
    output_path = build_output_path(path, config.dir, token.site.config.out_dir)

    output_path
    |> Path.dirname()
    |> File.mkdir_p!()

    File.write!(output_path, content)
  end

  defp render_template(path, token) do
    path
    |> File.read!()
    |> EEx.eval_string(assigns: [token: token, config: token.site.config])
  end

  defp build_output_path(source_path, source_dir, out_dir) do
    relative_path =
      source_path
      |> Path.relative_to(source_dir)
      |> String.replace_suffix(".eex", "")

    Path.join(out_dir, relative_path)
  end
end
