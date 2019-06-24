require 'webdrivers'
require 'watir'
require 'sqlite3'
require 'pp'
require 'net/http'
require 'nokogiri'

def getCitations(browser)

  # google scholar url
  # https://scholar.google.com/

  create a new watir object
  browser = Watir::Browser.new :chrome

  # get all the article titles from the database

  # load database
  db = SQLite3::Database.new("irse.db")

  # Select query
  selectArtNames = "SELECT * from article"

  # Update query
  updateCitation = "UPDATE article SET timesCited=? WHERE title=?"

  # Actual db query
  articles = db.execute(selectArtNames)
  #
  # articles should now be an array of the article names

  # Enter the name of each article into google scholar search bar,
  # hit the search button,
  # and retrieve the number of citations for that article
  articles.each do |article|

    #enter article name into search bar text field
    browser.text_field(name: 'q'). set article

    # hit the search button
    browser.button(name: 'btnG').click

    # check if the first search result has the same name as article
    browser.links.each do |link|

      # if the link text is the same as the article name then it is the right link
      if link.text == article

        link.click
        citation = browser.p(class: 'c-article-metrics-bar__count').text

        # add the citation number to the database
        db.execute(updateCitation, citation, article)

      end

    end

  end

end


