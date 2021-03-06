# Pull the docker image
docker pull cloudera/quickstart

# after docker pull

docker run -m 4g --hostname=quickstart.cloudera --privileged=true -t -i -v /Users/li/Desktop/playground/hadoop/dataset:/src --publish-all=true -p 8888 cloudera/quickstart /usr/bin/docker-quickstart

# Check if all services are running once started the container 
jps 

# switch to user cloudera, once in the linux terminal, avoid using the root user   
su - cloudera 

# copy files
Note to add the local directory in Docker file sharing option, otherwise the copy would fail.  

docker cp <filename> <containername>:<target_path_in_docker> (part after the comma is the path in the container) 
docker cp googleplaystore.csv epic_keller:/home/cloudera
docker cp googleplaystore_user_reviews.csv epic_keller:/home/cloudera

(note we are copying to /home/cloudera because this is the home folder of the user cloudera that we have switched to) 

# Return to the docker container, Use the command line interface, go to Hive shell

hive 

# Commands once in the hive shell 
show databases;
create database if not exists demo;
use demo; -- go inside the demo database 
set hive.cli.print.current.db = true; -- setting the property to display current database 

# create a hive table 
# Move the file from linux server into Hadoop /HDFS location
cd <folder_containing_files>
hadoop fs -mkdir hive_input #create a location on HDFS to store the files
hadoop fs -put <path>/txns.txt hive_input 

# use HUE to interact with our Hadoop services 
# user: cloudera, pwd: cloudera 

# display rows in a file 
hadoop fs -cat hive_input/txns.txt | head -5
# notice the file doesn't have headers. 

# create a hive table 
# go to hive shell, select the db to use 
hive
use demo
# check table 
show tables; 
desc <tablename>;
desc formatted <tablename>; 

create table transactions (txn_date string, customer_id bigint, txn_amount double, category string, product string, city string, state string, txn_type string) row format delimited fields terminated by ',';

# internal tables vs external tables 
# internal tables: managed by hive, the metadata is managed by hive, data resides inside the hive warehouse 

# check the metastore, on the mysql server 
# open another terminal,connect to the existing docker container, go to the mysql shell (log in as root)
mysql -u root -p

TBLS 
COLUMNS_V2

## TIP:
docker ps -- get the container name 
docker exec -it <container name> /bin/bash 

# Load data 
## from a local filesystem 
load data local inpath '/home/cloudera/files/txns.txt' [overwrite] into table transactions;
 -- the location of files on the linux server 
 -- optional overwrite command instead of inserting 

# hive writing is very fast because it is shcema on read; in comparison, oracle/mysql is schema on write (schema is verified when writing to tables). 

# Notice that the local file is also copied to hive.warehouse 

## load data from HDFS location 
load data inpath '/user/cloudera/hive_input/txns.txt' into table transactions_cp;
# note if loading from HDFS location, the data is MOVED, not copied to the hive.warehouse sub folder. the data from the HDFS location is gone. 

# External tables

create external table customers(cust_id bigint, firstname string, lastname string, age int, profession string) 
    row format delimited fields terminated by ','
    location '/user/cloudera/customer';

note: 1.have to specify 'external' keyword; 
2. have to provide the external location where the underlying data is. 
3. Internal tables the underlying data is under hive.warehouse, external tables the underlying data is somewhere else on the HDFS system, not managed by Hive. 
4. No need to load the data, because the table is already on top of the HDFS location where the data is. 
5. New data will need to be in the same schema and format (same deliminators for example)

select * from customers limit 5;

### when to use internal vs external tables; 
1. Both tables metadata is managed by metastore;
2. If internal table is dropped, both the data and metadata are lost;  
3. If external table is dropped, the data is still there in the external location, while metadata is lost;
4. In production env better to use external tables, more secure with respect to data loss. 

# Partitioning 
How to select the partition column?
- need to be present, frequently consumed;
- need to have low cardinality (small number of distinct values), because each partition will create a sub directory, might cause namenode to process too much metadata;

# Bucketing 
If need to partition on a high cardinality column to solve performance issue, bucketing is a better solution to minimize metadata. 
The number of buckets can be controlled:
    - Integer columns: buckets can be created/assigned by : hashfunction(column_value) = output_integer, output_integer%number of buckets  
    - String columns can use the same method too, where a hashfunction converts string to an integer 
When to use bucketing? 
    - when data set is huge, and downstream consumes subsets
    - when cardinality is high 
    - when using Sort Merge Bucket join between 2 big tables 

# Partition vs Bucket 
IMPORTANT - REVIEW!!

# Static Partitioning 

## create a table first (internal this time)
create table transactions_part(date string, cust_id bigint, amount double,product string, city string, state string) partitioned by (category string) row format delimited fields terminated by ',';
# schema without the partition column 

# load data into partition, when loading, must explicit provide the partition value 
load data inpath '/user/cloudera/hive_input/gym_txns.txt' into table transactions_part partition(category='Gymnastics');
# when to use static partitioning 
If the files arrive in already partitioned fashion, i.e. all rows belonging to 1 category are in the same file. 

# DYNAMIC PARTITION 

create table transactions_dy_part(date string, cust_id bigint, amount double,product string, city string, state string) partitioned by (category string) row format delimited fields terminated by ',';

## before loading data, set these properties 
set hive.exec.dynamic.partition = true; 
set hive.exec.dynamic.partition.mode = nonstrict; 

## if the partition.mode is strict, dynamic loading is not allowed, also query without a where clause is not allowed; 

## load the data:
    - normally load data into a staging table without partitions
    - from that staging table, insert into the dynamically partitioned table:
        insert into table <destination_table> partition(partition_column) select [columns] from <source_table> ;
        (note that the partition column is always selected last)   
??? if i loaded data into hive warehouse, then it's not on hdfs anymore, does replication still work? 
??? hive.warehouse = HDFS?  


# Bucketing 
## create the table. We have to select all columns. In comparison, when doing partitioning, we are leaving out the partition column.
## bucketing on the product column, which has 150 distinct values 

create table transactions_bucket(txt_date string, cust_id bigint, txn_amount double, category string, product string, city string, state string) clustered by (product) into 4 buckets row format delimited fields terminated by ',';
## note how to decide on the bucket size:
    - depends on the size of the file. could be the same size as a data block 
    - 2 to the power of n ( 4 buckets, 8 buckets, 16, 32,etc..)
## load the table. same as dynamic partition, direct load from files is not allowed, has to go through a staging table first 

set hive.exec.enforce.bucketing = true; 
insert into table transactions_bucket select txn_date, customer_id, txn_amount,category,product,city,state from transactions;

# Partitioning and Bucketing together (and even multi-column partitioning)
Scenario: there are different granularities in the data, e.g. country, state, city. 
country and state are reletively low cardinality compared to city, so we can partition on country and state, and bucket on city column. 
Note that bucket can only be done on 1 column. 

create table transactions_pb(txn_date string, cust_id bigint, txn_amount double, product string, city string, state string) partitioned by (category string) clustered by (product) into 2 buckets row format delimited fields terminated by ',';
insert into transactions_pb partition(category)
    > select txn_date, customer_id, txn_amount, product, city, state,category from transactions;


?? partition by date, it is high cardinality, but it is also a common practice? 

# Store Hive query output 
## to a location on linux server 
insert overwrite local directory <path> row format delimited fields terminated by ',' lines terminated by '\n' select category, sum(txn_amount) as total_amount from transactions group by category; 
## to hive HDFS directory 
insert overwrite directory '/user/cloudera/data' row format delimited fields terminated by ',' lines terminated by '\n' select category, sum(txn_amount) as total_amount from transactions group by category; 
## to another table 
create table category_sum row format delimited fields terminated by ',' AS select category, sum(txn_amount) as total_amount from transactions group by category; 


# Hive SerDe - serializer/deserializer 
Serialize at write, deserialize at read 
Default TEXTFILE 
More on SerDe: https://medium.com/@gohitvaranasi/how-does-apache-hive-serde-work-behind-the-scenes-a-theoretical-approach-e67636f08a2a

Scenario: data in a column contains comma, e.g. 'Fees for AWS, Azure', if we load table row format delimited by ',',
this will distort the output, 'Fees for AWS' ,'Azure' will be in 2 columns, and the value following might be lost. To tacle this, we need SerDe library. 

add jar file to hive shell 
use the class 

# ORC file format 
Stands for optimized row column , it is a compressed format 
Use orc when the data is going to be used as a lot of aggregates, for example, BI reports 


# SQOOP 

# Grant access to cloudera user 
mysql -u root -p (cloudera)
use mysql;
grant all privileges on *.* to 'cloudera'@'quickstart.cloudera' identified by 'cloudera' with grant option;

# check databases in linux 
## sqoop uses a jdbc connection to the rdbms 
sqoop list-databases --connect jdbc:mysql://quickstart.cloudera:3306 --username cloudera --password cloudera; 
sqoop list-tables --connect jdbc:mysql://quickstart.cloudera:3306/retail_db --username cloudera --password cloudera; 

## sqoop eval - quick assessment of the data in the RDBMS 
sqoop eval --connect <connection string to the db> --username username --password password --query '<query string>'
sqoop eval --connect jdbc:mysql://quickstart.cloudera:3306/retail_db --username cloudera --password cloudera --query 'select * from products limit 5'
### note that the query is executed by the engine of the RDBMS 






















