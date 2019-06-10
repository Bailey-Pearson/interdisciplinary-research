# Amber

require "mechanize"
require_relative "helpers"
require 'string_pattern'

def parseArguments()
    if ARGV.length < 1
        print "Not Enough Arguments\n"
    else
        helpers = Helpers.new
        url = ARGV[0]
        agent = helpers.getAgent()
        page = helpers.getPage(url,agent)
        #volumes = page.links_with(:text => %r{(2009|201[0-9])})
        #icse_regex = /^[^a-zA-Z]*$["ICSE "]/
        #ase_regex = /^[^a-zA-Z]*$["ASE "]/
        #fse_regex = /^[^a-zA-Z]*$["FSE "]/
        page.links.each do |link|
            if link.text.include?("ICSE ") | link.text.include?("ASE ") | link.text.include?("FSE ")
                #new_page = link.click
                print link
                print "\n"
            end
        end
    end
end


# [ link.match(icse), "ASE ", "FSE "].any? {|str| link.text.include? str} && !["CHASE", "CASES", "EASE", "ICSEB", "ICSET", "ITiCSE", "TEFSE"].any? {|str2| link.text.include? str2}

parseArguments()
