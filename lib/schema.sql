CREATE TABLE categories (
	id serial primary key,
	category_name text,
	description text,
	up_vote integer,
	down_vote integer
);

CREATE TABLE posts (
	id serial primary key,
	category_id integer,
	title text,
	body text,
	create_date date,
	expiration_date date,
	up_vote integer,
	down_vote integer
);

CREATE TABLE comments (
	id serial primary key,
	post_id integer,
	create_date date,
	up_vote integer,
	down_vote integer
);

CREATE TABLE subscriptions (
	id serial primary key,
	user_id integer,
	category_id integer,
	post_id integer,
	comment_id integer,
	cell text,
	email text
);