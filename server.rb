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
	File.read('./forms/category_new_form.html')
end
post "/categories" do
	Category.create(category_name: params[:category_name], description: params[:description], up_vote: 0, down_vote: 0)
	redirect "/categories"
end

get "/categories/:category_id" do
	all_categories = get_all_categories
	all_posts = get_all_posts

	category_to_display = []
	all_categories.each do |x|
		if x[:id] == params[:category_id].to_i
			category_to_display.push(x)
		end
	end

	posts_to_display = []
	all_posts.each do |x|
		if x[:category_id] == params[:category_id].to_i
			posts_to_display.push(x)
		end
	end

	Mustache.render(File.read('./views/category_single.html'), 
		category: category_to_display, posts: posts_to_display)
end

post "/categories/:category_id" do
	Post.create(category_id: params[:category_id].to_i, title: params[:title], body: params[:body], create_date: Date.current, up_vote: 0, down_vote: 0)

	#conditional: first search in subscriptions for category_id == params[:category_id] in this post section. if that exists, then pull the cell number and/or email address

	# then get the post with highest (.max?) id from category(params[:category_id]) 
	# if in posts category_id == category(params[:category_id]) then return post with highest id

	# now you have the cell number and the email and the newest post to communicate

	# now use Twilio and SendGrid (oy)


	redirect "/categories/#{params[:category_id]}"
end

post "/categories/:category_id/up_vote" do
	all_categories = get_all_categories
	category_to_update = {}
	all_categories.each do |x|
		if x[:id] == params[:category_id].to_i
			category_to_update = x
		end
	end
	Category.update(params[:category_id].to_i, up_vote: (category_to_update[:up_vote] + 1))
	redirect "/categories/#{params[:category_id]}"
end

post "/categories/:category_id/down_vote" do
	all_categories = get_all_categories
	category_to_update = {}
	all_categories.each do |x|
		if x[:id] == params[:category_id].to_i
			category_to_update = x
		end
	end
	Category.update(params[:category_id].to_i, down_vote: (category_to_update[:down_vote] + 1))
	redirect "/categories/#{params[:category_id]}"
end

#SUBSCRIPTIONS PAGES
get "/categories/:category_id/subscribe" do
	all_categories = get_all_categories
	all_posts = get_all_posts

	category_to_display = {}
	all_categories.each do |x|
		if x[:id] == params[:category_id].to_i
			category_to_display = x
		end
	end

	Mustache.render(File.read('./forms/category_subscribe_form.html'), 
		category_to_display)
end

post "/categories/:category_id/subscribe" do
	Subscription.create(user_id: 0, category_id: params[:category_id].to_i, post_id: 0, comment_id: 0, cell: params[:cell], email: params[:email])

	redirect "/categories/#{params[:category_id]}"
end



#POSTS PAGES
# get "/posts" do
# 	File.read ("./views/posts.html")
# end
# get "/posts/new" do
# end
# get "/posts/:post_id" do
# end

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