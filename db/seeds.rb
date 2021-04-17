puts "Cleaning database.."
User.destroy_all
Book.destroy_all
puts "Creating database.."

tom_user = User.new(email: "tomagnese@gmail.com", password: "123456")

tom_user.save