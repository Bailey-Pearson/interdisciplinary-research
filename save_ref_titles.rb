require 'sqlite3'
require 'csv'

def get_titles

  # Select query
  select = "SELECT title FROM reference"

  # Load database
  db = SQLite3::Database.new( "irse.db" )

  # Query database
  titles = db.execute(select)

  # Close the database
  db.close

  return titles

end

def sanitize_titles(titles)

  titles.each do |tit|
    unless tit[0] == ""
      tit[0] = tit[0].tr('-',' ')
      tit[0] = tit[0].tr('^a-zA-Z ','')
    end
  end

  return titles

end

def save_titles(titles)

  titles = sanitize_titles(titles)

  File.open('ref_titles.txt','w') do |f|

    titles.each do |tit|
      unless tit[0] == '' or tit[0] == ' '
        f << tit[0].strip
        f << ' '
      end
    end

  end

end

save_titles(get_titles)