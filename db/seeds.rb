# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user_params = [
  {
    email: "example@example.com",
    password: "password"
  }
]

User.delete_all
User.create!(user_params)
puts "ユーザーの初期データの投入に成功しました！"

post_params = [
  {
    user_id: 1,
    title: "React",
    content: "ユーザインターフェース構築のための JavaScript ライブラリ"
  },
  {
    user_id: 1,
    title: "Vue.js",
    content: "The Progressive JavaScript Framework"
  },
  {
    user_id: 1,
    title: "Angular",
    content: "モバイルとデスクトップ，ひとつのフレームワーク"
  }
]

Post.delete_all
Post.create!(post_params)
puts "Postの初期データの投入に成功しました！"

puts "すべての初期データの投入に成功しました！"
