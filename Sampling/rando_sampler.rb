require 'sqlite3'
require 'csv'

def get_sample(size)

  # Select query
  select = "SELECT * FROM reference"

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
  puts "\nPercent correct: " + (correct.to_f / total).to_s
  puts "Percent incorrect: " + ((total - correct).to_f / total).to_s
end

def save_edit_samples(sample)

  CSV.open("corrected_labels.csv","w",
           :write_headers=> true,
           :headers => ["title", "citation", "isCS"],
           :col_sep => "|") do |csv|
    sample.each do |samp|
      samp[2] = samp[2].to_s
      csv << samp
    end
  end

end

def confirm_labels

  # Ask user for sample size
  puts "Please enter a sample size (reasonably sized integer):"
  sample_size = gets

  # Retrieve a sample
  sample = get_sample(sample_size.to_i)

  # Query the user about each reference CS label
  correct_labels = 0
  remaining = sample_size.to_i
  sample.each do |samp|

    # Highly likely articles labeled as CS are correct
    if samp[2] == 1
      correct_labels += 1
      remaining -= 1
      next
    end

    puts "\nArticles remaining: " + remaining.to_s

    puts "\nIs this article labeled correctly? (y/n):\n"
    puts "Title: " + samp[0]
    puts "Citation: " + samp[1]

    if samp[2] == 0
      puts "Label: non-CS"
    else
      puts "Label: CS\n"
    end

    user_label = gets
    user_label = user_label.chomp

    while user_label.downcase != 'y' and user_label.downcase != 'n'
      puts "\nIncorrect input. Correct input: (y/n)"
      user_label = gets
      user_label = user_label.chomp
    end

    if user_label.downcase == 'y'
      correct_labels += 1
    end

    remaining -= 1

  end

  do_calculations(correct_labels,sample.count)

end

def edit_sample_labels

  # Ask user for sample size
  puts "Please enter a sample size (reasonably sized integer):"
  sample_size = gets

  # Retrieve a sample
  sample = get_sample(sample_size.to_i)

  # Query the user about each reference CS label
  remaining = sample_size.to_i
  sample.each do |samp|

    # Highly likely articles labeled as CS are correct
    if samp[2] == 1
      remaining -= 1
      next
    end

    puts "\nArticles remaining: " + remaining.to_s

    puts "\nIs this article labeled correctly? (y/n):\n"
    puts "Title: " + samp[0]
    puts "Citation: " + samp[1]

    if samp[2] == 0
      puts "Label: non-CS"
    else
      puts "Label: CS\n"
    end

    user_label = gets
    user_label = user_label.chomp

    while user_label.downcase != 'y' and user_label.downcase != 'n'
      puts "\nIncorrect input. Correct input: (y/n)"
      user_label = gets
      user_label = user_label.chomp
    end

    # switch sample label
    if user_label.downcase == 'n'
      if samp[2] == 0
        samp[2] = 1
      else
        samp[2] = 0
      end
    end

    remaining -= 1

  end

  save_edit_samples(sample)

end

srand
#query_user
edit_sample_labels
