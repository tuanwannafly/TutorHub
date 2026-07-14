Rails.backtrace_cleaner.add_silencer { |line| line =~ /\/(?:gems|ruby)\// && !line.match(/minitest/) }
