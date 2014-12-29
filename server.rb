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

def get_all_subs
	all_subscriptions = Subscription.all.each
	all_subscriptions
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

get "/categories/delete" do
	all_categories = get_all_categories
	Mustache.render(File.read('./forms/category_delete_form.html'), category: all_categories)
end
delete "/categories/delete" do
	all_posts = get_all_posts
	all_categories = get_all_categories

	category_to_display = []
	all_categories.each do |x|
		if params[:id].to_i == x[:id] 
			category_to_display.push(x)
		end
	end

	posts_in_category_to_delete = []
	all_posts.each do |x|
		if params[:id].to_i == x[:category_id]
			posts_in_category_to_delete.push(x)
		end
	end

	if posts_in_category_to_delete.length > 0
		Mustache.render(File.read('./views/category_cannot_delete_because_posts_exist.html'), category: category_to_display)
	else
		Category.delete(params[:id].to_i)
		redirect "/categories"
	end
	
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
	all_subs = get_all_subs
	all_posts = get_all_posts
	Post.create(category_id: params[:category_id].to_i, title: params[:title], body: params[:body], create_date: Date.current, up_vote: 0, down_vote: 0)

	cell_array = []
	all_subs.each do |x|
		if params[:category_id].to_i == x[:category_id]
			cell_array.push(x[:cell])
		end
	end
	#now we have the cell(s) that have subscribed to the given category in an array

	email_array = []
	all_subs.each do |x|
		if params[:category_id].to_i == x[:category_id]
			email_array.push(x[:email])
		end
	end
	#now we have the email(s) that have subscribed to the given categry in an array

	posts_to_sort = []
	all_posts.each do |x|
		if params[:category_id].to_i == x[:category_id]
			posts_to_sort.push(x)
		end
	end

	ids_of_posts_to_sort = posts_to_sort.map {|x| x[:id]}
	most_recent_post = ids_of_posts_to_sort.max

	post_to_send = posts_to_sort.find {|x| x[:id] == most_recent_post}
	#now we have the most recent post to send and the information for where to send it

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
	Category.update(params[:category_id].to_i, up_vote: (category_to_update[:up_vote] - 1))
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