# Data Engineering on Hadoop Hands-on 
With a small section on theory. I will be using the cloudera/quickstart sandbox (docker) in this project, for trying Hadoop in a production environment on AWS, stay tuned for part2. (CDP private cloud base development cluster, connect aws services)

This project doesn’t demonstrate all the theories or capabilities of Hadoop, and might be hard to follow if you don’t have previous knowledge of the ecosystem. For a highlighted introduction to Hadoop, you can go to these resources: [links],[my study notes].

# Introduction & Goals
This is a pragmatic guide to the essential Hadoop services. 
#### The goals:
Understand what each essential component is and how they work
Know how to build a batch processing data pipeline using Hadoop
Common optimization techniques
You will be able to set up file  transfers, hive warehouses, tables in hive, import and export from a relational DB, orchestration.     

#### Executive summary:
I will be using the transactions dataset 
Docker and terminal. cloudera/quickstart docker image
What are you doing with these tools
Once you are finished add the conclusion here as well

#### Contents
The Data Set
Used Tools
Pipeline 
Optimization techniques:
Partition, bucketing 
Hadoop performance tuning 
Demo
Conclusion
Follow Me On
Appendix

# The Data Set
I’m using the dataset [link to git] prepared by [author name], the folder contains a typical transactions data
Why did you choose it? Easy to understand for learning purposes  
What is problematic? These files are actually very small, which is not the case in real life. 
We are going to experiment all Hadoop and Hive operations with this dataset. 

# Used Tools
Explain which tools do you use and why
How do they work (don't go too deep into details, but add links)
Why did you choose them
How did you set them up

#### Docker 
Why use it? It provides a very easy starting point for us to experiment with Hadoop from a single laptop, we don’t need to worry about complicated installation, configuration, servers…

Link to the cloudera/quickstart image and documentation. 

Commands: pull & run, settings - file sharing, 

#### Cloudera docker image
It simulates a complete linux environment with hadoop ecosystem, hive, HDFS, Hue, Hive metastore. You can interact with it from the command line and from the webUI which is Hue. 

# Pipeline Overview
Connect - batching processing - storage 
* In this case, we will not include the buffer and visualization layers 
* Demonstrate a batch processing pipeline, this is what MapReduce is best for. 

Preparation -> Creating the tables 
We will cover how to create tables in the class notes. 

Before going on to build our pipeline, we should always inspect the data

What are the schemas, the file sizes, any data quality issues that need to be handled? 
What are the unique values columns? 
What are the primary keys and foreign keys? 

# Pipelines


Import transactional data from a relational DB once every day, create a summary snapshot and put the results in an analytics-dedicated table.
Requirements and specs:   
Cadence daily
No changes on the previous transactions are allowed - incremental update on last value 
Tune performance, analysts often need to filter on date and city columns. 
Export the table to another data warehouse. 

Import files into the mysql database. Create transaction tables. In real life, you would get transaction data into your mysql database, but since we are simulating, we will put some csv files into mysql database and pretend it’s the transactions.

Use sqoop to import the data into hive tables. 



Check the metadata

Automation 
Set up automation using cron. (In an enterprise environment you would probably use something like airflow to orchestrate your jobs for better visibility and collaboration, however this tutorial is not about airflow, so let’s stick to the easy cron job). 

Hive performance tuning - briefly discusses a few optimization techniques

Create partitions and buckets 
Compression 
Optimize joins 
Use ORC file format 
Avoid global sort (order by clause) 


# Demo
You could add a demo video here: recording 
Or link to your presentation video of the project

# Conclusion
Write a comprehensive conclusion.
How did this project turn out
What major things have you learned
What were the biggest challenges

# Follow Me On
Add the link to your LinkedIn Profile

# Appendix
Mapreduce performance tuning: http://hadooptutorial.info/hadoop-performance-tuning/

Hive performance tuning: http://hadooptutorial.info/hive-performance-tuning/

Concurrency in hive: https://cwiki.apache.org/confluence/display/Hive/Locking

Hortonworks Hadoop certification: https://hortonworks.com/wp-content/uploads/2015/02/DataSheet_HDPCD_2.21.pdf

Handle null string values in the partition column 
Hadoop architecture: https://data-flair.training/blogs/hadoop-architecture/
Hadoop architecture: https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html





