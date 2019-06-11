require 'webdrivers'
require "watir"
require 'pp'

#  main()
#  This method creates the browsers connection to the website
#  It also calls all other methods to get the needed information
def main()
    # The list of links to issues that fall between 2018-2009
    issueLinks = []
    # The list of links to all articles that are within the issues
    articleLinks = []


    # Open the browser connection
    browser = Watir::Browser.new
    url = "https://ieeexplore.ieee.org/xpl/issues?punumber=32&isnumber=8714098"
    browser.goto(url)

    # Wait until the javascript is loading before attempting to click
    browser.element(title: "All Issues").wait_until(&:present?)

    # Gather issues from the 2010s
    browser.link(text: '2010s').click
    issueLinks = getIssueLinks(issueLinks, browser)

    # Gather issues from the 2000s
    browser.link(text: '2000s').click
    issueLinks = getIssueLinks(issueLinks, browser)

    # Retrieve the articles from each of the found issues
    totalIssues = issueLinks.count
    currentIssue = 0
    issueLinks.each do |issueLink|
        currentIssue += 1
        print "Issue " + currentIssue + " out of " + totalIssues + "\n\n"
        articleLinks = getArticleLinks(issueLink, articleLinks, browser)
    end

    # Currently recieving nill/empty links so get rid of them
    # TODO figure out why the empties are showing up
    articleLinks.reject!{|e| e.nil? || e.to_s.empty? }
    
    # Gather the information needed from each of the articles
    totalArticles = articleLinks.count
    currentArticle = 0
    articleLinks.each do |article|
        currentArticle += 1
        print "Article " + currentArticle + " out of " + totalArticles + "\n\n"
        getInformation(article)
    end
    
    # Close the browser at the end of the session
    browser.close
end


#  getIssueLinks()
#                                                   
#  Clicks on any volume between 2009 and 2018 and retrieves all of the issue links
#  @param   issueLinks =>  array of all issue links
#  @param   browser    =>  current browser location
#  @return  the updated issueLinks array
def getIssueLinks(issueLinks, browser)
    browser.links.each do |volume|
        if volume.text.to_i >= 2009 && volume.text.to_i <= 2018 && !volume.text.include?("s")
            volume.click
            browser.links.each do |issue|
                if issue.text.include?("Issue") && !issue.text.include?("Current") && !issue.text.include?("All")
                    issueLinks << issue.href
                end
            end
        end
    end
    return issueLinks
end

#  getArticleLinks()
#                                                   
#  Opens an issue and retrieves the links to every article associated with it
#  @param   issueLink       =>  link to the issue currently being looked at
#  @param   articleLinks    =>  array of all article links
#  @param   browser         =>  current browser location
#  @return  the updated articleLinks array
def getArticleLinks(issueLink, articleLinks, browser)
    browser.goto(issueLink)
    browser.element(class: ["results-actions", "hide-mobile"]).wait_until(&:present?)
    browser.links.each do |article|
        if article.href.include?("document") && !article.href.include?("media") && !article.href.include?("citations")
            articleLinks << article.href
        end
    end
    return articleLinks
end

main()
