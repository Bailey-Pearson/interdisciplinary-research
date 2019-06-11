require 'webdrivers'
require "watir"
require 'pp'

def main()
    browser = Watir::Browser.new
    url = "https://ieeexplore.ieee.org/xpl/issues?punumber=32&isnumber=8714098"

    browser.goto(url)
    browser.element(title: "All Issues").wait_until(&:present?)

    issues = []
    articles = []

    browser.link(text: '2010s').click

    issues = getIssues(issues, browser)

    browser.link(text: '2000s').click

    issues = getIssues(issues, browser)

    issues.each do |issue|
        articles = getArticles(issue, articles, browser)
    end

    print "Total Article Count: "
    print articles.count
    print "\n\n\n"

    articles.each do |article|
        print article
        print "\n\n"
    end
    
    browser.close
end

def getIssues(issues, browser)
    browser.links.each do |volume|
        if volume.text.to_i >= 2009 && volume.text.to_i <= 2018 && !volume.text.include?("s")
            volume.click
            browser.links.each do |issue|
                if issue.text.include?("Issue") && !issue.text.include?("Current") && !issue.text.include?("All")
                    issues << issue.href
                end
            end
        end
    end
    return issues
end

def getArticles(issue, articles, browser)
    print "getting url of article \n"
    url = issue
    browser.goto(url)
    browser.element(class: ["results-actions", "hide-mobile"]).wait_until(&:present?)
    browser.links.each do |article|
        if article.href.include?("document") && !article.href.include?("media") && !article.href.include?("citations")
            articles << article.href
        end
    end
    return articles
end

main()
