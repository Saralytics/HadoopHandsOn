-- First of all, we need to simulate the transaction database, to do that, we will create 2 tables in the MYSQL DB in the docker container
-- When inside the container, switch to user cloudera, and log into MYSQL db  

mysql -u root -p (password is cloudera)

-- Check the databases available 
show databases;
-- Let's say retail_db is where we decide to put the google app store data, let's switch to that database.
use retail_db;
show tables;

-- Now create the tables that will store the data;
create table apps (
app varchar(200),
category varchar(100),
rating double,
reviews bigint,
size varchar(50),
installs varchar(50),
type varchar(10),
price varchar(50),
content_rating varchar(50),
genres varchar(50),
last_updated varchar(100),
current_ver varchar(50),
android_ver varchar(50),
inserted_on timestamp default current_timestamp,
PRIMARY KEY (app));

-- load data in to apps table 

LOAD DATA INFILE '/home/cloudera/input_files/googleplaystore.csv'
INTO TABLE apps
COLUMNS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- after loading, let's check if all the rows are inserted using the linux command 
cat googleplaystore.csv  | wc -l

-- repeat the above process to load the other file 

create table apps_reviews (
app varchar(200),
translated_review varchar(2000),
sentiment varchar(20),
sentiment_polarity varchar(100),
sentiment_subjectivity varchar(100),
inserted_on timestamp default current_timestamp);

-- load data in to apps table 

LOAD DATA INFILE '/home/cloudera/input_files/googleplaystore_user_reviews.csv'
INTO TABLE apps_reviews
COLUMNS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
