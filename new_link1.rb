require 'webdrivers'
require 'watir'

def main

  # create browser object
  browser = Watir::Browser.new :firefox

  link1 = 'https://dl.acm.org/citation.cfm?id=3180155'
  link2 = 'https://dl.acm.org/citation.cfm?id=3097368'
  link3 = 'https://dl.acm.org/citation.cfm?id=3097368'
  link4 = 'https://dl.acm.org/citation.cfm?id=2884781'

  # links = ['https://dl.acm.org/citation.cfm?id=3180155', 'https://dl.acm.org/citation.cfm?id=3097368',
  # 'https://dl.acm.org/citation.cfm?id=3097368', 'https://dl.acm.org/citation.cfm?id=2884781',
  # 'https://dl.acm.org/citation.cfm?id=2818754', 'https://dl.acm.org/citation.cfm?id=2819009',
  # 'https://dl.acm.org/citation.cfm?id=2568225', 'https://dl.acm.org/citation.cfm?id=2486788',
  # 'https://dl.acm.org/citation.cfm?id=2337223', 'https://dl.acm.org/citation.cfm?id=1806799',
  # 'https://dl.acm.org/citation.cfm?id=1810295', 'https://dl.acm.org/citation.cfm?id=1555001',
  # 'https://dl.acm.org/citation.cfm?id=1747491', 'https://dl.acm.org/citation.cfm?id=1858996',
  # 'https://dl.acm.org/citation.cfm?id=2190078', 'https://dl.acm.org/citation.cfm?id=2351676',
  # 'https://dl.acm.org/citation.cfm?id=3107656', 'https://dl.acm.org/citation.cfm?id=2642937',
  # 'https://dl.acm.org/citation.cfm?id=2970276', 'https://dl.acm.org/citation.cfm?id=3155562',
  # 'https://dl.acm.org/citation.cfm?id=3238147', 'https://dl.acm.org/citation.cfm?id=1595696',
  # 'https://dl.acm.org/citation.cfm?id=2491411', 'https://dl.acm.org/citation.cfm?id=2786805',
  # 'https://dl.acm.org/citation.cfm?id=3106237', 'https://dl.acm.org/citation.cfm?id=3236024']

  article_links = []

  # visit link
  browser.goto(link1)

  # wait for page to load
  browser.element(title: "Contact The DL Team").wait_until(&:present?)

  # hit single page view
  browser.link(text: 'single page view').click

  # wait for page to load
  browser.element(title: "PDF").wait_until(&:present?)

  # get all of the links on that page and filter out article links
  browser.links.each do |link2|
    if link2.href.include?('citation.cfm?') and link2.attribute_list.count == 1 and link2.text != 'tabbed view' and !link2.text.include?('Editorial')
      article_links << link2.href
    end
  end

  getInformation(article_links, browser)

  print "FINSIHED" + "\n"
  browser.close

end


def getInformation(article_links, browser)

  authors = []
  references = []

  article_links.each do |art_link|
    # go to the article of interest
    browser.goto(art_link)
    print browser.url
    print "\n"

    # wait for the page to load
    browser.element(text: "PDF").wait_until(&:present?)

    # get the author names
    # if the href contains 'author', add it to the authors

    # get all reference links for that article
    reference_links = browser.divs.select{|d| d.attribute_list.count == 0 and d.parent.tag_name == 'td'}
    reference_links.each do |r_link|
      references << r_link
    end

    # get all the h1's
    #h1s = browser.h1s

    #h1s.each do |h1|
    # print h1.text
    #end


    # get the number of cited by
    references.each do |omg|
      print omg + "\n"
    end
  end
end


main