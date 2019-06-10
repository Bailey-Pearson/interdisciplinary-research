require 'webdrivers'
require "watir"

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
        url = issue.href
        if url.include?("ieeexplore")
            url = issue.href
            print issue.text
            print "\n"
            print url
            print "\n\n"
            # getArticles(issue, articles, browser)
        end
    end
    
    browser.close
end

def getIssues(issues, browser)
    browser.links.each do |volume|
        if volume.text.to_i >= 2009 && volume.text.to_i <= 2018 && !volume.text.include?("s")
            volume.click
            browser.links.each do |issue|
                if issue.text.include?("Issue") && !issue.text.include?("Current") && !issue.text.include?("All")
                    issues << issue
                end
            end
        end
    end
    return issues
end

def getArticles(issue, articles, browser)
    url = issue.href
    print issue.text
    print "\n"
    print url
    print "\n\n"
    # if url.include?("xpl")
    #     browser.goto(url)
    #     browser.element(class: ["results-actions", "hide-mobile"]).wait_until(&:present?)
    #     browser.links.each do |article|
    #         if article.href.include?("document") && !article.href.include?("media") && !article.href.include?("citations")
    #             print article.text
    #             print "\n"
    #         end
    #     end
    # end
end

main()
