# TableauEexExtension

[![Hex Version](https://img.shields.io/hexpm/v/tableau_eex_extension?style=for-the-badge "Hex Version")](https://hex.pm/packages/mdex_custom_heading_id)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg?style=for-the-badge "Hex Docs")](https://hexdocs.pm/tableau_eex_extension)
[![Apache 2.0](https://img.shields.io/hexpm/l/tableau_eex_extension?style=for-the-badge&label=licence "Apache 2.0")](https://github.com/halostatue/mdex_custom_heading_id/blob/main/LICENCE.md)
![Coverage](https://img.shields.io/coverallsCoverage/github/halostatue/tableau_eex_extension?style=for-the-badge "Coverage")

- code :: <https://github.com/halostatue/tableau_eex_extension>
- issues :: <https://github.com/halostatue/tableau_eex_extension/issues>

A Tableau extension that renders EEx templates to static files during site
generation. Templates have access to the Tableau token and site configuration,
making it easy to generate files like `robots.txt`, `humans.txt`, or other
well-known files with dynamic content.

## Installation

Add `tableau_eex_extension` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tableau_eex_extension, "~> 1.0"}
  ]
end
```

Documentation is found on [HexDocs][docs].

## Semantic Versioning

TableauEexExtension follows [Semantic Versioning 2.0][semver].

[docs]: https://hexdocs.pm/tableau_eex_extension
[hexpm]: https://hex.pm/packages/tableau_eex_extension
[licence]: https://github.com/halostatue/tableau_eex_extension/blob/main/LICENCE.md
[semver]: https://semver.org/
