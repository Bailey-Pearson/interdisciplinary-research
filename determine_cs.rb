require 'csv'
require 'sqlite3'

def is_cs(reference)

  # Open and read file
  file = open('cs_titles.csv','r').read
  titles = CSV.parse(file, :quote_char => '|')

  # Check if the cited journal is present in our known cs journals
  if titles.include? reference
    return true
  end

  return false

end

def update_cs(db,reference,cs)

  # Update query
  update = "UPDATE reference SET isCS=? WHERE title=?"

  # Perform update
  db.execute(update,cs,reference)

end

def update_db

  # Select query
  select = "SELECT title FROM reference"

  # Load database
  db = SQLite3::Database.new( "irse.db" )

  # Get all reference titles from database
  references = db.execute(select)

  # Check each ref and update database
  references.each do |ref|
    if is_cs(ref)
      update_cs(db,1,ref)
    else
      update_cs(db,0,ref)
    end
  end

  # Close database
  db.close

end

update_db