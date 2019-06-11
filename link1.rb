# Amber Lopata

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
        icse_regex1 = Regexp.compile(%r{.*[\s;:,-/]+ICSE[\s;:,-/]+.*})
        icse_regex2 = Regexp.compile(%r{^ICSE[\s;:',-/]+.*})
        icse_regex3 = Regexp.compile(%r{.*ICSE$})
        ase_regex = Regexp.compile(%r{^ASE[\s;:',-/]+.*})
        fse_regex = Regexp.compile(%r{.*[\s;:,-/]+FSE[\s;:,-/]+.*})
        page.links.each do |link|
            if fse_regex.match?(link.text) | ase_regex.match?(link.text) | icse_regex1.match?(link.text) | icse_regex2.match?(link.text) | icse_regex3.match?(link.text)
                #new_page = link.click
                print link
                print "\n"
            end
        end
    end
end


# [ link.match(icse), "ASE ", "FSE "].any? {|str| link.text.include? str} && !["CHASE", "CASES", "EASE", "ICSEB", "ICSET", "ITiCSE", "TEFSE"].any? {|str2| link.text.include? str2}

parseArguments()


# ase_regex.match?(link.text) | fse_regex.match?(link.text) | icse_regex.match?(link.text)