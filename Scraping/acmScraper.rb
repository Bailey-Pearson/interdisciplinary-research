require 'webdrivers'
require 'watir'
require 'sqlite3'
require 'pp'
require 'net/http'
require 'nokogiri'

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

  # Load database
  db = SQLite3::Database.new( "/home/taylor/Documents/RIT-REU/interdisciplinary-research/cs_papers.db" )

  # Update query
  update = "UPDATE article SET year=? WHERE title=?"

  # For each volume
  volumes.each do |vol|

    # Visit volume
    browser.goto(vol)

    # Grab the volume's year
    year = browser.img(src: "images/ACM_mini.jpg").parent.text[0..3].to_i

    # Grab all Article links
    vol_toc = browser.links(href: %r{citation\.cfm\?id=[0-9]*})

    # Filter out editorials and any extra non-article links
    vol_toc = vol_toc.select {|link|
      link.attribute_list.count == 1 and link.text != 'tabbed view' and !link.text.include? "Editorial"}

    # Place each article link into the article array
    # update the article's year in the database
    vol_toc.each do |link|
      articles << [link.text,link.href]
      db.execute(update,year,link.text)
    end

  end

  db.close

  # Return the array of article links
  return articles

end

def storeArticleData(browser,articles)

  artCount = articles.count
  citeErrors = 0

  # Load database
  db = SQLite3::Database.new( "irse.db" )

  # Insert Queries
  insertArticle = "INSERT INTO article(title) VALUES (?)"
  insertAuthor = "INSERT INTO author(name) VALUES (?)"
  insertReference = "INSERT INTO reference(title, citation) VALUES (?, ?)"
  insertWrite = "INSERT INTO write(author, article) VALUES (?, ?)"
  insertCite = "INSERT INTO cite(article, reference) VALUES (?, ?)"
  checkArticle = "SELECT * from article where title = ?"
  checkAuthor = "SELECT * from author where name = ?"
  checkRefs = "SELECT * from reference where title = ?"
  checkWrite = "SELECT * from write where author = ? and article = ?"
  checkCite = "SELECT * from cite where article = ? and reference = ?"

  # For each article
  articles.each do |art|

    # Skip articles already added to database
    unless db.execute(checkArticle, art[0]) == []
      print "Article '" + art[0] + "' already scraped and stored.\n"
      artCount -= 1
      next
    end

    print "\nArticles left to scrape: " + artCount.to_s + "\n"

    # Visit article
    browser.goto(art[1])
    print "Scraping article: '" + art[0] + "'\n"

    # Compile list of article's resources (refs)
    refs = browser.divs.select{|d| d.attribute_list.count == 0 and d.parent.tag_name == 'td' and
        d.parent.parent.parent.parent.previous_sibling.present? and
        !d.parent.parent.parent.parent.previous_sibling.text.include? "Citations"}

    # Don't need articles with no references
    unless refs.count > 0
      puts "No references present for article."
      artCount -= 1
      next
    end

    # Compile list of article's authors
    auths = browser.links.select{|a| a.title == 'Author Profile Page' and a.parent.previous_sibling.text != 'Editor'}

    print "Data scraped.\n"

    # Store author information in database
    auths.each do |auth|
      if db.execute(checkAuthor, auth.text) == []
        db.execute(insertAuthor, auth.text)
      end
      if db.execute(checkWrite, auth.text, art[0]) == []
        db.execute(insertWrite, auth.text, art[0])
      end
    end

    print "Authors stored.\n"

    # Store reference data in database
    refs.each do |ref|

      # Used to check reference format
      head = ref.text.chars.first(1).join

      # Use FreeCite API to parse reference
      uri = URI('http://freecite.library.brown.edu/citations/create')
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.post('/citations/create',
                             'citation=' + ref.text,
                             'Accept' => 'text/xml')

        # Some responses were returning empty due to some error
        if response.body == " "
          citeErrors += 1
          puts "!!! REFERENCE ERROR !!!"
          titleNode = "FreeCite response error #" + citeErrors.to_s + "for article: '" + art[0] + "'"

          if db.execute(checkRefs, titleNode) == []
            db.execute(insertReference, titleNode, ref.text)
          end
          if db.execute(checkCite, art[0], titleNode) == []
            db.execute(insertCite, art[0], titleNode)
          end
        else
          bodyXML = Nokogiri::XML(response.body)
          citationNode = bodyXML.at_xpath('//citation')

          # Some reference formats cause parser to put title in author node
          if head.to_i.to_s == head # Title is in author node
            titleNode = citationNode.at_xpath('//author')
          else
            titleNode = citationNode.at_xpath('//title')
          end

          unless titleNode.nil?
            if db.execute(checkRefs, titleNode.content) == []
              db.execute(insertReference, titleNode.content, ref.text)
            end
            if db.execute(checkCite, art[0], titleNode.content) == []
              db.execute(insertCite, art[0], titleNode.content)
            end
          end
        end
      end
    end

    print "References stored.\n"

    # Insert article into database
    db.execute(insertArticle, art[0])

    print "Article stored.\n"

    artCount -= 1
  end

end

def runAmber(links)

  # Get Watir browser and go to ACM TOSEM page
  browser = Watir::Browser.new :chrome
  browser.goto "https://dl.acm.org/citation.cfm?id=J790"

  # Switch to single page view
  browser.link(text: 'single page view').click

  articles = getArticles(browser,links)
  #storeArticleData(browser,articles)

end

def runTaylor

  # Get Watir browser and go to ACM TOSEM page
  browser = Watir::Browser.new :chrome
  browser.goto "https://dl.acm.org/citation.cfm?id=J790"

  volumes = getVolumes(browser)
  articles = getArticles(browser,volumes)
  #storeArticleData(browser,articles)

end

def main

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

main
