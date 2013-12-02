# Blog settings
Time.zone = "Tokyo"

activate :blog do |blog|
  blog.prefix = "blog"
  # blog.permalink = ":year/:month/:day/:title.html"
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

# Layout
page "blog/*", :layout => :post
page "/feed.xml", :layout => false

# Directory
set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'
set :layouts_dir, 'layouts'
set :partials_dir, 'partials'

# Slim
Slim::Engine.set_default_options :pretty => true
Slim::Engine.set_default_options :shortcut => {
  '#' => {:tag => 'div', :attr => 'id'},
  '.' => {:tag => 'div', :attr => 'class'},
  '&' => {:tag => 'input', :attr => 'type'}
}

# Markdown 
set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

# LiveReload
activate :livereload

# Autoprefixer
activate :autoprefixer, browsers: ['last 2 versions', 'ie 9']

# Build setting
configure :build do
  activate :minify_css
  activate :gzip
  # activate :minify_javascript
  activate :imageoptim
end
