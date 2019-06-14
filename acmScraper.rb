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

  # Arrays to hold Article and Author objects
  articleObjs = []
  authorObjs = []

  # For each article
  articles.each do |art|

    # Visit article
    browser.goto(art[1])

    # Compile list of article's authors
    # May need reworked (Mauro Pezze may not always be the editor. Also nothing says the editor can't also author a paper.)
    auths = browser.links.select{|a| a.title == 'Author Profile Page' and a.text != 'Mauro Pezzè'}
    authtexts = []
    auths.each do |auth|
      authtexts << auth.text
    end

    # Compile list of article's resources (refs)
    refs = browser.divs.select{|d| d.attribute_list.count == 0 and d.parent.tag_name == 'td'}
    reftexts = []
    refs.each do |ref|
      reftexts << ref.text
    end

    # Create an Article object for this article
    article = Article.new(art[0],reftexts,0,authtexts)

    # add it to Article object array
    articleObjs << article

    # For each author
    authtexts.each do |auth|
      # Make an author object and add it to the author object array
      author = Author.new(auth,art[0])
      authorObjs << author
    end

    puts "\nArticle Name: " + article.name
    puts "\nReferences: "
    article.references.each do |ref|
      puts ref
    end
    puts "\nAuthors: "
    authorObjs.each do |auth|
      puts auth.name
    end

  end

  # Return array with articleObjs as first elem and authorObjs as second elem
  return [articleObjs,authorObjs]

end

links = ['https://dl.acm.org/citation.cfm?id=3180155', 'https://dl.acm.org/citation.cfm?id=3097368',
         'https://dl.acm.org/citation.cfm?id=3097368', 'https://dl.acm.org/citation.cfm?id=2884781',
         'https://dl.acm.org/citation.cfm?id=2818754', 'https://dl.acm.org/citation.cfm?id=2819009',
         'https://dl.acm.org/citation.cfm?id=2568225', 'https://dl.acm.org/citation.cfm?id=2486788',
         'https://dl.acm.org/citation.cfm?id=2337223', 'https://dl.acm.org/citation.cfm?id=1806799',
         'https://dl.acm.org/citation.cfm?id=1810295', 'https://dl.acm.org/citation.cfm?id=1555001',
         'https://dl.acm.org/citation.cfm?id=1747491', 'https://dl.acm.org/citation.cfm?id=1858996',
         'https://dl.acm.org/citation.cfm?id=2190078', 'https://dl.acm.org/citation.cfm?id=2351676',
         'https://dl.acm.org/citation.cfm?id=3107656', 'https://dl.acm.org/citation.cfm?id=2642937',
         'https://dl.acm.org/citation.cfm?id=2970276', 'https://dl.acm.org/citation.cfm?id=3155562',
         'https://dl.acm.org/citation.cfm?id=3238147', 'https://dl.acm.org/citation.cfm?id=1595696',
         'https://dl.acm.org/citation.cfm?id=2491411', 'https://dl.acm.org/citation.cfm?id=2786805',
         'https://dl.acm.org/citation.cfm?id=3106237', 'https://dl.acm.org/citation.cfm?id=3236024']



def runAmber(links)

  # Get Watir browser and go to ACM TOSEM page
  browser = Watir::Browser.new :firefox
  browser.goto "https://dl.acm.org/citation.cfm?id=J790"

  # Switch to single page view
  browser.link(text: 'single page view').click

  articles = getArticles(browser,links)


  articleData = encapArticleData(browser,articles)

  articleData[0].each do |art|
    puts "\n" + art.name
  end

  articleData[1].each do |auth|
    puts "\n" + auth.name
  end

end


def runTaylor

  # Get Watir browser and go to ACM TOSEM page
  browser = Watir::Browser.new :firefox
  browser.goto "https://dl.acm.org/citation.cfm?id=J790"

  volumes = getVolumes(browser)
  articles = getArticles(browser,volumes)
  articleData = encapArticleData(browser,articles)

  articleData[0].each do |art|
    puts "\n" + art.name
  end

  articleData[1].each do |auth|
     puts "\n" + auth.name
  end

end


# Choose which one to run:
# runAmber(links)
# runTaylor()

