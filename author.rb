class Author

  attr_reader :name
  attr_reader :articles

  def initialize(name,articles)
    @name = name
    @articles = articles
  end

  def addArticle(article)
    @articles << article
  end
end
