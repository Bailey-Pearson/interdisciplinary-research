require "mechanize"
require_relative "helpers"
require_relative "article"
require_relative "author"

def getArticles()
    if ARGV.length < 1
        print "Not Enough Arguments\n"
    else
        helpers = Helpers.new
        url = ARGV[0]

        # Set up agent ang get page specified in ARGV[0]
        agent = helpers.getAgent()
        #agent.user_agent_alias = "Linux Mozilla"
        page = helpers.getPage(url,agent)

        # Switch to single page view
        singleview_page = page.link_with(:text => 'single page view').click

        # Get all links to Volumes published after 2008
        volumes = singleview_page.links_with(:text => %r{(2009|201[0-9])})

        # This line may need reworked, but it works for now.
        volumes = volumes.drop(4)

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
end

getArticles().each do |link|
  puts link
end
