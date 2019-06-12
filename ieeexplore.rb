require 'webdrivers'
require "watir"
require 'pp'
require_relative "author.rb"
require_relative "article.rb"

#  main()
#  This method creates the browsers connection to the website
#  It also calls all other methods to get the needed information
def main()
    # The list of links to issues that fall between 2018-2009
    issueLinks = []
    # The list of links to all articles that are within the issues
    articleLinks = []
    # The list of article objects
    articles = []
    test = Author.new("Marc Palyart", ["just testin"])
    # The list of author objects
    authors = [test]


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
        print "Issue " + currentIssue.to_s + " out of " + totalIssues.to_s + "\n\n"
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
        print "Article " + currentArticle.to_s + " out of " + totalArticles.to_s + "\n\n"
        articles, authors = getInformation(article, articles, authors, browser)
    end
    
    print "Articles: \n"
    pp articles
    print "\n Authors: \n"
    pp authors
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
                    return issueLinks
                end
            end
        end
    end
    # return issueLinks
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
            articleLinks << [article.href, article.text]
            # return articleLinks
        end
    end
    return articleLinks
end

def getInformation(articleLink, articlesList, authorsList, browser)
    name = articleLink[1]
    references = []
    citedBy = []
    authors = []

    # Go to the article and wait for it to load
    browser.goto(articleLink[0])
    browser.element(class: ["document-header-title-container", "col"]).wait_until(&:present?)

    # Open the references tab
    browser.link(text: 'References').fire_event(:onclick)
    browser.element(id: "references").wait_until(&:present?)
    referenceDivs = browser.divs(class: "reference-container")

    # Collect the references from the divs
    referenceDivs.each do |referenceDiv|
        spans = referenceDiv.spans()
        spanCounter = 0
        spans.each do |span|
            spanCounter += 1
            if spanCounter == 2 && !span.text.empty?
                references << span.text
            end
        end
    end

    #Get Authors
    authorDiv = browser.div(class: "authors-info-container")
    authorLinks = authorDiv.as()
    authorLinks.each do |author|
        if !author.text.empty?
            if !authorsList.any?{|knownAuthor| knownAuthor.name == author.text}
                if references.count != 0 && name != ""
                    authorObject = Author.new(author.text, [name])
                    authorsList << authorObject
                    authors << authorObject
                end
            else
                if references.count != 0 && name != ""
                    index = authorsList.find_index {|knownAuthor| knownAuthor.name == author.text}
                    authorObject = authorsList[index]
                    authorObject.addArticle(name)
                    authors << authorObject
                end
            end
        end
    end

    if references.count != 0 && name != ""
        article = Article.new(name, references, citedBy, authors)
        articlesList << article
    end

    return articlesList, authorsList
end

main()
