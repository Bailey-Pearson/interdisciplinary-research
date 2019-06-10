require "mechanize"
require_relative "helpers"

def parseArguments()
    if ARGV.length < 1
        print "Not Enough Arguments\n"
    else
        helpers = Helpers.new
        url = ARGV[0]
        agent = helpers.getAgent()
        page = helpers.getPage(url,agent)
        page.links.each do |link|
            print link
            print "\n"
        end
    end
end

parseArguments()
