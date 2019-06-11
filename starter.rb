require "mechanize"
require_relative "helpers"
require_relative "article"
require_relative "author"


def getVolumes(url)

    helpers = Helpers.new

    # Set up agent and get page specified by URL
    agent = helpers.getAgent()
    #agent.user_agent_alias = "Linux Mozilla"
    page = helpers.getPage(url,agent)

    # Switch to single page view
    singleview_page = page.link_with(:text => 'single page view').click

    # Get all links to Volumes published after 2008
    volumes = singleview_page.links_with(:text => %r{(2009|201[0-9])})

    # This line may need reworked, but it works for now.
    volumes = volumes.drop(4)

    return volumes

end

def getArticles(volumes)

    # Array to hold article links
    articles = []

    # Follow Volume links and navigate to corresponding Table of Contents
    volumes.each do |vol|

        # Visit volume
        vol_page = vol.click

        # Grab all Article links
        vol_toc = vol_page.links_with(:href => %r{citation\.cfm\?id=[0-9]*})
        vol_toc = vol_toc.select {|link| link.attributes.values.count == 1 and link.text != 'tabbed view' and !link.text.include? "Editorial"}

        # Place each article link into the article array
        vol_toc.each do |link|
            articles << link
        end
    end

    # Return the array of article links
    return articles

end

def encapArticleData(articles)

    # Follow article links
    articles.each do |link|

        article_page = link.click

        # Compile list of article's authors
        authors = article_page.links_with(:href => %r{author_page\.cfm\?id=[0-9]*})
        authors.each do |auth|
            puts auth
        end

        # Compile list of article's resources (refs)
        ref_divs = article_page.bases#.find_all { |d| d.attributes.parent.attributes.attribute(style) == 'padding: 10px;'}
        ref_divs.each do |ref|
            puts ref.attributes#.text
        end

        # Compile list of article citations
        #unless article_page.search("div").at("div:contains('Citings are not available')") == nil

        #end
    end
end

volumes = getVolumes("https://dl.acm.org/citation.cfm?id=J790")
articles = getArticles(volumes)
encapArticleData(articles)
