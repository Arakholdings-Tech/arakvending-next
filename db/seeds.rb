# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Machine.create!

(1..60).each do |seq|
  Product.create(
    name: "Product #{seq}",
    quantity: 7,
    price: rand(99..9000),
    selection: seq,
    machine: Machine.first
  )
end
