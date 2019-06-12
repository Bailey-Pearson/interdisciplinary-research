require 'webdrivers'
require 'watir'

def main

  # create browser object
  browser = Watir::Browser.new

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

  article_links = []

  # visit all of the links
  links.each do |link|
    # open up page
    browser.goto(link)

    # wait for page to load
    browser.element(title: "Contact The DL Team").wait_until(&:present?)

    # hit table of contents tab
    browser.button(text: 'Table of Contents').click

    # wait for page to load
    browser.element(title: "Contact The DL Team").wait_until(&:present?)

    # get all of the links on that page and filter out article links
    browser.links.each do |link2|
      #if link2.href.include?('citation')
      #  article_links << link2
      print link2.text
      end
    end

  # visit each article link
  #article_links.each do |link|
  #  browser.goto(link.href)
  #  print link.text
  #  print "\n"
  #end
  #article_links.each do |link3|
   # print link3.text
    #print"\n"
  #end
  #print article_links.count + "\n"
  print "finished"
  browser.close
end

def getInformation(article_link)

  authors = []
  references = []
  title
  cited_by


  # go to the article of interest
  browser.goto(article_link)

  # wait for the page to load
  browser.element(text: "Contact The DL Team").wait_until(&:present?)

  # get all of the links on that article page
  links = browser.links.collect

  links.each do |link|

    # get the author names
    # if the href contains 'author', add it to the authors
    if link.href.include?('author')
      authors << link.text
    end

    # hit the references button
    browser.button(text: 'Table of Contents').click

    # wait for page to load
    browser.element(text: "Contact The DL Team").wait_until(&:present?)

    # get all links on page
    reference_links = browser.links.collect
    reference_links.each do |r_link|
      if r_link.href.include?('citation')

        # add this reference link to references array
        references << r_link
      end
    end

    # get all the h1's
    h1s = browser.h1s

    h1s.each do |h1|
      print h1.text
    end


    # get the number of cited by

  end
end

main