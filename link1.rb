# Amber Lopata

require "mechanize"
require_relative "helpers"
require 'string_pattern'

def getLinks()
    if ARGV.length < 1
        print "Not Enough Arguments\n"
    else
        helpers = Helpers.new
        url = ARGV[0]
        agent = helpers.getAgent()
        page = helpers.getPage(url,agent)
        links_correct_years = page.links_with(:text => %r{(2009|201[0-9])})
        icse_regex1 = Regexp.compile(%r{.*[\s;:,-/]+ICSE[\s;:,-/]+.*})
        icse_regex2 = Regexp.compile(%r{^ICSE[\s;:',-/]+.*})
        icse_regex3 = Regexp.compile(%r{.*ICSE$})
        ase_regex = Regexp.compile(%r{^ASE[\s;:',-/]+.*})
        fse_regex = Regexp.compile(%r{.*[\s;:,-/]+FSE[\s;:,-/]+.*})

        links = []
        links_correct_years.each do |link|
            if fse_regex.match?(link.text) | ase_regex.match?(link.text) | icse_regex1.match?(link.text) | icse_regex2.match?(link.text) | icse_regex3.match?(link.text)
                links << link
                print link
                print "\n"
            end
        end
    end
    #return links
end

def getArticles()

    articles = []
    page_links = getLinks()
    page_links.each do |page_link|
        print page_link
        print "\n"
    end
end


getLinks()
