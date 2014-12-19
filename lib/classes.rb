require 'active_record'

class Category < ActiveRecord::Base
	has_many :posts
end

class Post < ActiveRecord::Base
	has_many :comments
end

class Comment < ActiveRecord::Base
	belongs_to :posts
end

class User < ActiveRecord::Base
end

class Subscription < ActiveRecord::Base
end