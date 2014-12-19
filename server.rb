require './lib/connection.rb'
require './lib/classes.rb'
require 'sinatra'
require 'sinatra/reloader'
require 'mustache'
require 'pry'

# methods for getting data from database HERE
def get_all_categories
	all_categories = Category.all.each
	all_categories
end

def get_all_posts
	all_posts = Post.all.each
	all_posts
end

#HOMEPAGE
get "/" do
	File.read("./views/homepage.html")	
end

#CREATOR
get "/creator" do
	File.read("./views/creator.html")
end

#CATEGORIES PAGES
get "/categories" do
	all_categories = get_all_categories
	all_posts = get_all_posts
	Mustache.render(File.read("./views/categories.html"), { categories: all_categories, posts: all_posts} )
end
get "/categories/new" do

end
get "/categories/:category_id" do
	binding.pry
	all_categories = get_all_categories
	all_posts = get_all_posts
	all_posts.each do |post|
		post
	end

end

#POSTS PAGES
get "/posts" do
	File.read ("./views/posts.html")
end
get "/posts/new" do

end
get "/posts/:post_id" do

end

#COMMENTS PAGES (necessary?)
get "/comments" do
	File.read ("./views/comments.html")
end
get "/comments/new" do

end
get "/comments/comment_id" do

end

#USERS PAGES
get "/users" do

end
get "/users/new" do

end
get "/users/user_id" do

end