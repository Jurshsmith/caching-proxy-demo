defmodule CachingProxyDemoWeb.PageHTML do
  use CachingProxyDemoWeb, :html

  embed_templates "page_html/*"
end
