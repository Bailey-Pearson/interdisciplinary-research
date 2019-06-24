require 'webdrivers'
require 'watir'
require 'nokogiri'

def getTitles(browser, url)

  # Page position
  pos = 1

  # Array to hold all the titles
  titles = []

  # Go to url
  browser.goto url

  # Go through all the pages
  while browser.link(text: '[next 100 entries]').attribute_value('class') != 'disabled'

    # Grab all links on the page
    links = browser.div(class: 'hide-body').links

    # Update page position
    pos += links.count

    # Add page's titles to all titles array
    links.each do |link|
      titles << link.text
    end

    # Go to next page
    browser.goto url + "?pos=" + pos.to_s

  end

  return titles

end

# Get Watir browser
browser = Watir::Browser.new :chrome

# Get titles for cosci conferences
conferences = getTitles(browser,"https://dblp.org/db/conf/")

# Get titles for cosci journals
journals = getTitles(browser,"https://dblp1.uni-trier.de/db/journals/")

puts "Conferences:"
conferences.each do |title|
  puts title
end

puts "\nJounrals:"
journals.each do |title|
  puts title
end