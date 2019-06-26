require 'sqlite3'

def get_sample(size)

  # Select query
  select = "SELECT title, isCS FROM reference"

  # Load database
  db = SQLite3::Database.new( "irse.db" )

  # Query database
  refs = db.execute(select)

  # Close the database
  db.close

  # Randomly select a sample of size 'size' from references
  sample = []
  while size > 0
    sample << refs[rand * (refs.count - 1)]
    size -= 1
  end

  return sample

end

def do_calculations(correct,total)
  puts "Percent correct: " + (correct / total).to_s
  puts "Percent incorrect: " + ((total - correct) / total).to_s
end

def query_user

  # Ask user for sample size
  puts "Please enter a sample size (reasonably sized integer):"
  sample_size = gets

  # Retrieve a sample
  sample = get_sample(sample_size.to_i)

  # Query the user about each reference CS label
  correct_labels = 0
  sample.each do |samp|

    puts "\nIs this article labeled correctly? (y/n):\n"
    puts "Title: " + samp[0]

    if samp[1] == 0
      puts "Label: non-CS"
    else
      puts "Label: CS\n"
    end

    user_label = gets

    if user_label.downcase != 'y' and user_label.downcase != 'n'
      puts "\nIncorrect input. Correct input: (y/n)"
      next
    end

    if user_label.downcase == 'y'
      correct_labels += 1
    end

  end

  do_calculations(correct_labels,sample.count)

end

srand
query_user
