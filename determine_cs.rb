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

update_db