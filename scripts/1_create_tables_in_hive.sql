-- To be able to import data to hive tables, we need to define schemas in hive first

-- Go into hive shell
hive 

show databases;
create database if not exists demo;
use demo; 

-- set the property if you want to display the current db 
set hive.cli.print.current.db = true;

-- Create tables 

create table app () row format delimited fields terminated by ',';
