require "mechanize"

class Helpers

	def getAgent()
		agent = Mechanize.new
		agent.user_agent_alias = 'Windows Mozilla'
		return agent
	end
	
	# Method to use mechanize to get the initial homepage
	#
	# @param {string} url the website url
	# @return {object} the page object
	def getPage(url, agent)
		begin
		    page = agent.get url
		    return page
		rescue Mechanize::ResponseCodeError => e 
			return "bad"
		end  
	end
end