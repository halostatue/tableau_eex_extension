defmodule TableauEexExtensionTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  doctest TableauEexExtension

  describe "config/1" do
    test "converts list to map with defaults" do
      assert {:ok, %{enabled: false, dir: "_eex"}} = TableauEexExtension.config([])
    end

    test "merges map with defaults" do
      assert {:ok, config} = TableauEexExtension.config(%{dir: "templates"})
      assert config.enabled == false
      assert config.dir == "templates"
    end

    test "overrides defaults" do
      assert {:ok, config} = TableauEexExtension.config(%{enabled: true, dir: "custom"})
      assert config.enabled == true
      assert config.dir == "custom"
    end
  end

  describe "post_write/1" do
    @tag :tmp_dir
    test "renders eex files from configured directory", %{tmp_dir: dir} do
      eex_dir = Path.join(dir, "eex")
      output_dir = Path.join(dir, "output")
      File.mkdir_p!(eex_dir)

      File.write!(Path.join(eex_dir, "test.txt.eex"), "Hello <%= @config.name %>")

      token = build_token(dir, %{dir: eex_dir}, %{name: "World"})

      assert {:ok, ^token} = TableauEexExtension.post_write(token)
      assert File.read!(Path.join(output_dir, "test.txt")) == "Hello World"
    end

    @tag :tmp_dir
    test "strips .eex extension from output files", %{tmp_dir: dir} do
      eex_dir = Path.join(dir, "eex")
      File.mkdir_p!(eex_dir)
      File.write!(Path.join(eex_dir, "robots.txt.eex"), "User-agent: *")

      token = build_token(dir, %{dir: eex_dir})

      assert {:ok, ^token} = TableauEexExtension.post_write(token)
      assert File.exists?(Path.join([dir, "output/robots.txt"]))
    end

    @tag :tmp_dir
    test "preserves directory structure", %{tmp_dir: dir} do
      eex_dir = Path.join(dir, "eex")
      nested_dir = Path.join(eex_dir, "nested/deep")
      File.mkdir_p!(nested_dir)
      File.write!(Path.join(nested_dir, "file.html.eex"), "<html></html>")

      token = build_token(dir, %{dir: eex_dir})

      assert {:ok, ^token} = TableauEexExtension.post_write(token)
      assert File.exists?(Path.join([dir, "output/nested/deep/file.html"]))
    end

    @tag :tmp_dir
    test "provides @token and @config to templates", %{tmp_dir: dir} do
      eex_dir = Path.join(dir, "eex")
      File.mkdir_p!(eex_dir)

      template = """
      Token: <%= inspect(@token.site.config.name) %>
      Config: <%= @config.url %>
      """

      File.write!(Path.join(eex_dir, "vars.txt.eex"), template)

      token = build_token(dir, %{dir: eex_dir}, %{name: "TestSite", url: "https://test.com"})

      assert {:ok, ^token} = TableauEexExtension.post_write(token)

      output = File.read!(Path.join([dir, "output/vars.txt"]))
      assert output =~ ~s(Token: "TestSite")
      assert output =~ "Config: https://test.com"
    end

    @tag :tmp_dir
    test "renders multiple files", %{tmp_dir: dir} do
      eex_dir = Path.join(dir, "eex")
      File.mkdir_p!(eex_dir)
      File.write!(Path.join(eex_dir, "one.txt.eex"), "one")
      File.write!(Path.join(eex_dir, "two.txt.eex"), "two")

      token = build_token(dir, %{dir: eex_dir})

      assert {:ok, ^token} = TableauEexExtension.post_write(token)
      assert File.read!(Path.join([dir, "output/one.txt"])) == "one"
      assert File.read!(Path.join([dir, "output/two.txt"])) == "two"
    end

    @tag :tmp_dir
    test "evaluates Elixir expressions in templates", %{tmp_dir: dir} do
      eex_dir = Path.join(dir, "eex")
      File.mkdir_p!(eex_dir)

      template = "<%= Date.to_iso8601(~D[2026-01-29]) %>"
      File.write!(Path.join(eex_dir, "date.txt.eex"), template)

      token = build_token(dir, %{dir: eex_dir})

      assert {:ok, ^token} = TableauEexExtension.post_write(token)
      assert File.read!(Path.join([dir, "output/date.txt"])) == "2026-01-29"
    end

    @tag :tmp_dir
    test "logs error and returns {:error, :fail} when template raises", %{tmp_dir: dir} do
      eex_dir = Path.join(dir, "eex")
      File.mkdir_p!(eex_dir)

      template = "<%= raise \"template error\" %>"
      File.write!(Path.join(eex_dir, "bad.txt.eex"), template)

      token = build_token(dir, %{dir: eex_dir})

      log =
        capture_log(fn ->
          assert {:error, :fail} = TableauEexExtension.post_write(token)
        end)

      assert log =~ "template error"
    end
  end

  defp build_token(tmp_dir, eex_config, site_config \\ %{}) do
    output_dir = Path.join(tmp_dir, "output")

    %{
      extensions: %{
        eex: %{config: eex_config}
      },
      site: %{
        config: Map.merge(%{out_dir: output_dir}, site_config)
      }
    }
  end
end
