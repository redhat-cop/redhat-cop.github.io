source "https://rubygems.org"

# github-pages cannot run on Ruby 4 (commonmarker requires Ruby < 4.0)
gem "jekyll", "~> 4.4"
gem "minima", "~> 2.5"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
  gem "jekyll-relative-links", "~> 0.8"
  gem "jekyll-sitemap", "~> 1.4"
end

gem "webrick", "~> 1.9"

group :test do
  gem "html-proofer", "~> 5.2"
end

# Windows only
gem "tzinfo-data", platforms: [:windows, :jruby]
gem "wdm", "~> 0.2.0" if Gem.win_platform?
