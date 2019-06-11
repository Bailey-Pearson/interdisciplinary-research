class Article

  attr_reader :name
  attr_reader :references
  attr_reader :citedBy
  attr_reader :authors

  def initialize(name,refs,citedBy=[],authors)
    @name = name
    @references = refs
    @citedBy = citedBy
    @authors = authors
  end
end
