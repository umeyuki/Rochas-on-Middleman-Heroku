###
# Blog settings
###

Time.zone = "Tokyo"

activate :blog do |blog|
  blog.prefix = "blog"
  # blog.permalink = ":title.html"
  # blog.sources = ":year-:month-:day-:title.html"
  blog.taglink = ":tag.html"
  blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  blog.summary_length = 200
  # blog.year_link = ":year.html"
  # blog.month_link = ":year/:month.html"
  # blog.day_link = ":year/:month/:day.html"
  blog.default_extension = ".md"
  blog.tag_template = "tag.html"
  # blog.calendar_template = "calendar.html"
  blog.summary_separator = /SPLIT_SUMMARY_BEFORE_THIS/
  # blog.paginate = true
  blog.per_page = 30
  # blog.page_link = "page/:num"
end

# page "blog/*", :layout => :post
page "/atom.xml", :layout => false

###
# Compass
###

# Susy grids in Compass
# First: gem install susy
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Slim settings
# Set slim-lang output style
Slim::Engine.set_default_options :pretty => true
# Set Shortcut
Slim::Engine.set_default_options :shortcut => {
  '#' => {:tag => 'div', :attr => 'id'},
  '.' => {:tag => 'div', :attr => 'class'},
  '&' => {:tag => 'input', :attr => 'type'}
}

# Markdown settings
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

# Middleman-Syntax Extention
# activate :rouge_syntax

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :layouts_dir, 'layouts'
set :partials_dir, 'partials'
# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :cache_buster

  # Use relative URLs
  # activate :relative_assets

  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher

  # Or use a different image path
  # set :http_path, "/Content/images/"
end


