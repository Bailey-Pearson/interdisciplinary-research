require 'webdrivers'
require 'watir'

browser = Watir::Browser.new

browser.goto('http://stackoverflow.com/')

puts browser.title

browser.close