CREATE TABLE categories (
	id serial primary key,
	category_name varchar(50),
	description varchar(255),
	up_vote integer,
	down_vote integer
);

CREATE TABLE posts (
	id serial primary key,
	category_id integer,
	title varchar(255),
	body text,
	create_date date,
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

CREATE TABLE users (
	id serial primary key,
	name varchar(255),
	email varchar(255),
	cell varchar(15),
	user_id integer
);

CREATE TABLE subscriptions (
	id serial primary key,
	user_id integer,
	category_id integer,
	post_id integer,
	comment_id integer
);