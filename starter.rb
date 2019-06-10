require "mechanize"
require_relative "helpers"

def parseArguments()
    if ARGV.length < 1
        print "Not Enough Arguments\n"
    else
        helpers = Helpers.new
        url = ARGV[0]

        # Set up agent ang get page specified in ARGV[0]
        agent = helpers.getAgent()
        agent.user_agent_alias = "Linux Mozilla"
        page = helpers.getPage(url,agent)

        # Switch to single page view
        singleview_page = page.link_with(:text => 'single page view').click

        # Get all links to Volumes published after 2008
        volumes = singleview_page.links_with(:text => %r{(2009|201[0-9])})
        volumes = volumes.drop(4)

        volumes.each do |vol|
            vol_page = vol.click.link_with(:text => 'table of contents').click
        end
    end
end

parseArguments()
