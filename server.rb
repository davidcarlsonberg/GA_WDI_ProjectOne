require './lib/connection.rb'
require './lib/classes.rb'
require 'sinatra'
require 'sinatra/reloader'
require 'mustache'
require 'twilio-ruby'
require 'sendgrid-ruby'
require 'will_paginate'
require 'will_paginate/active_record'
require 'will_paginate/array'
require 'redcarpet'
require 'pry'

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

get "/" do
	File.read("./views/homepage.html")	
end

get "/creator" do
	File.read("./views/creator.html")
end

get "/categories" do
	all_categories = get_all_categories
	all_posts = get_all_posts
	Mustache.render(File.read("./views/categories.html"), { categories: all_categories, posts: all_posts} )
end

get "/categories/new" do
	File.read('./forms/category_new_form.html')
end

get "/categories/delete" do
	all_categories = get_all_categories
	Mustache.render(File.read('./forms/category_delete_form.html'), category: all_categories)
end

get "/categories/:category_id/page/:page" do
	category = Category.find_by({id: params[:category_id]})

	posts = Post
		.where({category_id: params[:category_id]})
		.where('expiration_date > ? OR expiration_date IS NULL', Date.today)
		.paginate(:page => params[:page], :per_page => 10)

	posts_rev = posts.reverse
 
	expired_posts_exists = Post
		.where({category_id: params[:category_id]})
		.where('expiration_date < ?', Date.today).length > 0

	Mustache.render(File.read('./views/category_single.html'), {
		category: category, 
		posts: posts_rev.to_a, 
		next_page: posts.next_page, 
		previous_page: posts.previous_page, 
		expired_posts: expired_posts_exists
	})
end

get "/categories/:category_id/posts/:post_id" do
	posts = Post
		.where({category_id: params[:category_id]})
		.where({id: params[:post_id]})
	Mustache.render(File.read('./views/post_single.html'), posts: posts.to_a)	
end

get "/categories/:category_id/expired_posts" do
	expired_posts = Post
		.where({category_id: params[:category_id]})
		.where('expiration_date < ?', Date.current)
	Mustache.render(File.read('./views/posts_expired.html'), expired_posts: expired_posts.to_a)
end

get "/categories/:category_id/subscribe" do
	category = Category.where({id: params[:category_id].to_i}).to_a
	Mustache.render(File.read('./forms/category_subscribe_form.html'), {category: category})
end

get "/categories/:category_id/unsubscribe" do
	category = Category.where({id: params[:category_id].to_i}).to_a
	Mustache.render(File.read('./forms/category_unsubscribe_form.html'), 
		category: category)
end

get "/posts/:page" do
	posts = Post.paginate(:page => params[:page], :per_page => 10).to_a
	Mustache.render(File.read('./views/posts_by_page.html'), posts: posts, next_page: posts.next_page, previous_page: posts.previous_page)
end

post "/categories" do
	Category.create(category_name: params[:category_name], description: params[:description], up_vote: 0, down_vote: 0)
	redirect "/categories"
end

post "/categories/:category_id" do
	renderer = Redcarpet::Render::HTML.new
	markdown = Redcarpet::Markdown.new(renderer)
	rendered_title = markdown.render(params[:title])
	rendered_body = markdown.render(params[:body])

	Post.create(category_id: params[:category_id].to_i, title: rendered_title, body: rendered_body, create_date: Date.current, up_vote: 0, down_vote: 0, expiration_date: params[:expiration_date])

	subs = Subscription.where({category_id: params[:category_id].to_i}).to_a
	cells = subs.map{|x| x[:cell]}
	emails = subs.map{|x| x[:email]}

	posts_to_sort = Post.where({category_id: params[:category_id].to_i}).to_a

	ids_of_posts_to_sort = posts_to_sort.map {|x| x[:id]}
	most_recent_post = ids_of_posts_to_sort.max
	post_to_send = posts_to_sort.find {|x| x[:id] == most_recent_post}
#now we have the post to send
	category_name = Category.find(params[:category_id])
	twilio_number = "+12039042566"
	cells.each do |indiv_number|
		account_sid = "ACea0b3bc7d136da7ae7f867e1ca4984de"
		auth_token = "79d901fe9ef2849fcd6d2907be12ce04"
		@client = Twilio::REST::Client.new account_sid, auth_token
		message = @client.account.messages.create(
			:body => "Museic category #{category_name[:category_name]} has been updated. TITLE: #{post_to_send[:title]} BODY: #{post_to_send[:body]}",
			:to => "#{indiv_number}",
			:from => "#{twilio_number}"
		)
	end

	client = SendGrid::Client.new(
		api_user: "davidcarlsonberg",
		api_key: "SendGrid195"
	)
	emails.each do |indiv_email|
		client.send(SendGrid::Mail.new(
			to: "#{indiv_email}",
			from: "davidcarlsonberg@gmail.com",
			subject: "Museic category #{category_name[:category_name]} has been updated.",
			text: "TITLE: #{post_to_send[:title]} BODY: #{post_to_send[:body]}",
			html: "<h4>TITLE: #{post_to_send[:title]}</h4> <br><p>BODY: #{post_to_send[:body]}</p>"
		))
	end
	redirect "/categories/#{params[:category_id]}/page/1"
end

post "/categories/:category_id/up_vote" do
	category_to_update = Category.find(params[:category_id].to_i)
	Category.update(params[:category_id].to_i, up_vote: (category_to_update[:up_vote] + 1))
	redirect "/categories/#{params[:category_id]}/page/1"
end

post "/categories/:category_id/down_vote" do
	category_to_update = Category.find(params[:category_id].to_i)
	Category.update(params[:category_id].to_i, up_vote: (category_to_update[:up_vote] - 1))
	redirect "/categories/#{params[:category_id]}/page/1"
end

post "/categories/:category_id/subscribe" do
	cell = params[:cell].insert(0, "+1").gsub("-","")
	all_subs = get_all_subs

	category_to_display = Category.where(id: params[:category_id].to_i)

	sub = []
	all_subs.each do |x|
		if (x[:cell] == cell || x[:email] == params[:email]) && x[:category_id] == params[:category_id].to_i
			sub.push(x)
		end
	end

	# subs_new = Subscription
	# 	.where(category_id: params[:category_id].to_i)
	# 	.find_by(cell: cell)
	# 	.find_by(email: params[:email])

	if sub.empty?
		Subscription.create(user_id: 0, category_id: params[:category_id].to_i, post_id: 0, comment_id: 0, cell: cell, email: params[:email])
		redirect "/categories/#{params[:category_id]}/page/1"
	else
		Mustache.render(File.read('./views/already_subscribed.html'), category: category_to_display.to_a)
	end
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

delete "/categories/:category_id/unsubscribe" do
	all_subs = get_all_subs
	cell = params[:cell].insert(0, "+1").gsub("-","")

	subscription_to_delete = {}
	all_subs.each do |x|
		if x[:category_id] == params[:category_id].to_i && (x[:cell] == cell || x[:email] == params[:email])
			subscription_to_delete = x
		# elsif x[:category_id] == params[:category_id] && x[:email] == params[:email]
		# 	subscription_to_delete = x
		end
	end
	Subscription.delete(subscription_to_delete[:id])

	redirect "/categories/#{params[:category_id]}/page/1"
end