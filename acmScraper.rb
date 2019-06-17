require 'watir'
require 'sqlite3'
require 'pp'

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

def parseRefForTitle(reference)

  # Count # of periods
  periods = 0

  # Building onto this string
  refTitle = ""

  # Used to keep track of previous character
  prevChar = ""

  # Iterate over string
  reference.split("").each do |c|
    if periods == 2
      if c == "."
        ++periods
      else
        refTitle << c
      end
    else
      unless prevChar === prevChar.capitalize
        if c == "."
          ++periods
        end
      end
    end
    prevChar = c
  end

  return refTitle

end

def storeArticleData(browser,articles)

  # Load database
  db = SQLite3::Database.new( "irse.db" )

  # Insert Queries
  insertArticle = "INSERT INTO article(title) VALUES (?)"
  insertAuthor = "INSERT INTO author(name) VALUES (?)"
  insertReference = "INSERT INTO reference(title, citation) VALUES (?, ?)"
  insertWrite = "INSERT INTO write(author, article) VALUES (?, ?)"
  insertCite = "INSERT INTO cite(article, reference) VALUES (?, ?)"
  checkAuthor = "SELECT * from author where name = ?"
  checkRefs = "SELECT * from reference where title = ?"

  # For each article
  articles.each do |art|

    # Insert article into database
    print art[0] + "\n"
    db.execute(insertArticle, art[0])

    # Visit article
    browser.goto(art[1])

    # Compile list of article's authors
    auths = browser.links.select{|a| a.title == 'Author Profile Page' and a.parent.previous_sibling.text != 'Editor'}
    auths.each do |auth|
      if (db.execute(checkAuthor, auth.text))
        db.execute(insertAuthor, auth.text)
      end
      db.execute(insertWrite, auth.text, art[0])
    end

    # Compile list of article's resources (refs)
    refs = browser.divs.select{|d| d.attribute_list.count == 0 and d.parent.tag_name == 'td' and
      !d.parent.parent.parent.parent.previous_sibling.text.include? "Citations"}

    # Don't need articles with no references
    unless refs.count > 0
      next
    end

    refs.each do |ref|
      if ref.children[0].tag_name == 'a'
        browser.goto(ref.children[0])
        refTitle = browser.h1.text
      else
        refTitle = parseRefForTitle(ref.text)
      end
      if db.execute(checkRefs, refTitle)
        db.execute(insertReference, refTitle, ref.text)
      end
      db.execute(insertCite, art[0], refTitle)
    end

  end

end


def runAmber(links)

  # Get Watir browser and go to ACM TOSEM page
  browser = Watir::Browser.new :firefox
  browser.goto "https://dl.acm.org/citation.cfm?id=J790"

  # Switch to single page view
  browser.link(text: 'single page view').click

  articles = getArticles(browser,links)
  storeArticleData(browser,articles)

end


def runTaylor

  # Get Watir browser and go to ACM TOSEM page
  browser = Watir::Browser.new :firefox
  browser.goto "https://dl.acm.org/citation.cfm?id=J790"

  volumes = getVolumes(browser)
  articles = getArticles(browser,volumes)
  storeArticleData(browser,articles)

end


def main

  links = ['https://dl.acm.org/citation.cfm?id=3180155'] #, 'https://dl.acm.org/citation.cfm?id=3097368',
  #          'https://dl.acm.org/citation.cfm?id=3097368', 'https://dl.acm.org/citation.cfm?id=2884781',
  #          'https://dl.acm.org/citation.cfm?id=2818754', 'https://dl.acm.org/citation.cfm?id=2819009',
  #          'https://dl.acm.org/citation.cfm?id=2568225', 'https://dl.acm.org/citation.cfm?id=2486788',
  #          'https://dl.acm.org/citation.cfm?id=2337223', 'https://dl.acm.org/citation.cfm?id=1806799',
  #          'https://dl.acm.org/citation.cfm?id=1810295', 'https://dl.acm.org/citation.cfm?id=1555001',
  #          'https://dl.acm.org/citation.cfm?id=1747491', 'https://dl.acm.org/citation.cfm?id=1858996',
  #          'https://dl.acm.org/citation.cfm?id=2190078', 'https://dl.acm.org/citation.cfm?id=2351676',
  #          'https://dl.acm.org/citation.cfm?id=3107656', 'https://dl.acm.org/citation.cfm?id=2642937',
  #          'https://dl.acm.org/citation.cfm?id=2970276', 'https://dl.acm.org/citation.cfm?id=3155562',
  #          'https://dl.acm.org/citation.cfm?id=3238147', 'https://dl.acm.org/citation.cfm?id=1595696',
  #          'https://dl.acm.org/citation.cfm?id=2491411', 'https://dl.acm.org/citation.cfm?id=2786805',
  #          'https://dl.acm.org/citation.cfm?id=3106237', 'https://dl.acm.org/citation.cfm?id=3236024']


  # Ask user for input
  puts "Enter the number of the database(s) you would like to scrape:"
  puts "1) ICSE, FSE, and ASE"
  puts "2) TOSEM"
  #puts "3) TSE"

  # Get user choice
  choice = gets

  if choice.to_i == 1
    runAmber(links)
  end

  if choice.to_i == 2
    runTaylor
  end

  if choice.to_i != 2
    puts "Invalid input."
    main
  end

end

#main
#runTaylor
runAmber(['https://dl.acm.org/citation.cfm?id=3180155'])