require 'watir'
require 'pp'
require_relative "helpers"
require_relative "article"
require_relative "author"

def getVolumes(browser)

  # Switch to single page view
  browser.link(text: 'single page view').click

  # Get all links to Volumes published after 2008
  volumes = browser.links(text: %r{(2009|201[0-9])})

  # This line may need reworked, but it works for now.
  volumes = volumes.drop(4)

  # Grab just the hrefs of the Volume links
  links = []
  volumes.each do |vol|
     links << vol.href
  end

  return links

end

def getArticles(browser,volumes)

  # Array to hold article links
  articles = []

  # For each volume
  volumes.each do |vol|

    # Visit volume
    browser.goto(vol)

    # Grab all Article links
    vol_toc = browser.links(href: %r{citation\.cfm\?id=[0-9]*})

    # Filter out editorials and any extra non-article links
    vol_toc = vol_toc.select {|link|
      link.attribute_list.count == 1 and link.text != 'tabbed view' and !link.text.include? "Editorial"}

    # Place each article link into the article array
    vol_toc.each do |link|
      articles << [link.text,link.href]
    end

  end

  # Return the array of article links
  return articles

end

def encapArticleData(browser,articles)

  # For each article
  articles.each do |art|

    # Visit article
    browser.goto(art[1])

    # Compile list of article's authors
    authors = browser.links(href:  %r{author_page\.cfm\?id=[0-9]*})

    # Compile list of article's resources (refs)


  end

end

# Get Watir browser and go to ACM TOSEM page
browser = Watir::Browser.new :firefox
browser.goto "https://dl.acm.org/citation.cfm?id=J790"

volumes = getVolumes(browser)
articles = getArticles(browser,volumes)

