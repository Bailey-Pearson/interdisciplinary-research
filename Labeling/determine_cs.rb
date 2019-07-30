require 'csv'
require 'sqlite3'

def is_cs(reference,titles)

  # Check if journal or title is substring of reference
  titles[0].each do |title|
    unless title.nil?
      if reference[0].include? title
        return true
      end
    end
  end

  return false

end

def update_cs(db,cs,reference)

  # Update query
  update = "UPDATE reference SET isCS=? WHERE citation=?"

  # Perform update
  db.execute(update,cs,reference[0])

end

def update_db

  # Select query
  select = "SELECT citation FROM reference"

  # Open and read file
  file = open('cs_titles.csv','r').read
  titles = CSV.parse(file, :quote_char => '|')

  # Load database
  db = SQLite3::Database.new( "irse.db" )

  # Get all reference titles from database
  references = db.execute(select)

  refs = references.count

  # Check each ref and update database
  references.each do |ref|
    puts "References left: " + refs.to_s
    if is_cs(ref,titles)
      update_cs(db,1,ref)
      puts "Reference is CS"
    else
      update_cs(db,0,ref)
      puts "Reference is NON-CS"
    end
    refs -= 1
  end

  # Close database
  db.close

end

def calculate_percentage

  # Select queries
  selectArts = "SELECT title FROM article"
  selectAuths = "SELECT author FROM write WHERE article=?"
  selectRefs = "SELECT reference FROM cite WHERE article=?"
  selectLabel = "SELECT isCS FROM reference WHERE title=?"

  # Update query
  updateAuths = "UPDATE article SET numAuths=? WHERE title=?"
  updateCS = "UPDATE article SET percentNonCS=? WHERE title=?"


  # Load database
  db = SQLite3::Database.new( "/home/taylor/Documents/RIT-REU/interdisciplinary-research/cs_papers.db" )

  # Get article titles
  articles = db.execute(selectArts)

  # For each article
  articles.each do |art|

    nonCSCount = 0

    # Grab the article's references
    references = db.execute(selectRefs,art)

    # Grab the article's authors
    authors = db.execute(selectAuths,art)

    # Update article's number of authors in database
    db.execute(updateAuths,authors.count,art)

    # For each reference
    references.each do |ref|

      # Get ref's isCS labels
      labels = db.execute(selectLabel,ref)

      # For each label
      labels.each do |label|

        # Update non-CS counter if reference is non-CS
        unless label[0] == 1
          nonCSCount += 1
        end

      end

    end

    # Calculate non-CS percentage
    percentage = 0
    unless references.count == 0
      percentage = (nonCSCount.to_f / references.count) * 100
    end

    # Update article in database w/ percentage
    db.execute(updateCS,percentage,art)

  end

  # Close database
  db.close

end

#update_db
calculate_percentage