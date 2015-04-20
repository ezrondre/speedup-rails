
3.times do |i|
  user = User.create(email: "test#{i}@test.com")
  rand(10).times do |j|
    Post.create(subject: "Post #{i}-#{j}", content: "Testing post for user #{user.id}", author_id: user.id)
  end
end
