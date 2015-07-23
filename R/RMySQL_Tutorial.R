## MySQL database and R
## by Tomas Mawyin

## This is an overview of how to create and manipulate MySQL databases from R.
## In order for this to work, make sure you have MySQL installed. Also, it is 
## important to note that each database is treated as a data frame in R.

## All the commands shown in this tutorial can be used directly in MySQL

## We will create a database that holds students grades for different courses.

## Files to use: scores.txt and students.csv

library(RMySQL)

## ----------------------------------------------------
## First, make a connection to the database
psswd <- "Tomasito84$"
mydb <- dbConnect(MySQL(), user="tmawyin", password=psswd, host="localhost")

## Let's check what databases exist. dbGetQuery sends, fetches, and clears query
dbGetQuery(mydb, "SHOW DATABASES;")

## Create a new database called "testingDB". Don't worry, we'll delete it soon enough
dbSendQuery(mydb, "CREATE DATABASE testingDB")

## How do we delete it? Easy, let's send the drop command
dbSendQuery(mydb, "DROP DATABASE IF EXISTS testingDB")

## Let's create the "school" database
dbSendQuery(mydb, "CREATE DATABASE school")

## Always disconnect the connection after using it.
dbDisconnect(mydb)

## ----------------------------------------------------
## Now, that we have the database, it's easier if we make a connection to
## the database directly.
mydb <- dbConnect(MySQL(), user="tmawyin", password=psswd, host="localhost", db="school")

## Let's double check that we are using the right database. This should print "school"
dbGetQuery(mydb, "SELECT DATABASE();")

## TABLE 1
## We can now create our first table - let's do the "students" table
## Note: You can do create and populate a table from a data frame but
## it is better to create tables this way so that you specify each data type.
dbSendQuery(mydb, "CREATE TABLE students(
            first_name VARCHAR(30) NOT NULL,
            last_name VARCHAR(30) NOT NULL,
            email VARCHAR(60) NULL,
            street VARCHAR(50) NOT NULL,
            city VARCHAR(40) NOT NULL,
            state CHAR(2) NOT NULL DEFAULT 'PA',
            zip MEDIUMINT UNSIGNED NOT NULL,
            phone VARCHAR(20) NOT NULL,
            birth_date DATE NOT NULL,
            sex ENUM('M', 'F') NOT NULL,
            date_entered TIMESTAMP,
            lunch_cost FLOAT NULL,
            student_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY);")

## Let's show some features before we populate:
## 1) Listing all tables from the database
dbListTables(mydb)

## 2) Listing all fields from a table
dbListFields(mydb, "students")

## 3) Showing the fields and descriptions from a table
dbGetQuery(mydb, "DESCRIBE students;")

## Let's insert the first value in the table using a query
dbSendQuery(mydb, "INSERT INTO students VALUES('Dale', 'Cooper', 'dcooper@aol.com', 
    '123 Main St', 'Yakima', 'WA', 98901, '792-223-8901', '1959-2-22',
	'M', NOW(), 3.50, NULL);")

## Let's add more values this time from a data frame
# Readin the file first and matching table names *very important!
student.df <- read.csv("students.csv", header = F, stringsAsFactors = FALSE)
colnames(student.df) <- dbListFields(mydb, "students")

## Writing to table
dbWriteTable(mydb, name='students', value=student.df, append= TRUE, row.names= FALSE, allow.keywords = FALSE)

## NOTES:
## The TIMESTAMP value is a bit tricky to pass using a file and required more work.
## In MySQL you can load data directly from a file using the command:
## LOAD DATA LOCAL INFILE '/path/students.txt' INTO TABLE students;

## But we want to see the table and the data. If you get warnings don't worry
dbGetQuery(mydb, "SELECT * FROM students;")

## TABLE 2
## Let's do another table called "class"
dbSendQuery(mydb, "CREATE TABLE class(
            name VARCHAR(30) NOT NULL,
            class_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY);")

## We can check how the table looks
dbGetQuery(mydb, "DESCRIBE class;")

## A smaller table is easier to populate by doing a quick data frame
class.df <- data.frame(name = c("English","Speech","Literature","Algrebra","Geometry","Trigonometry",
                                "Chemistry","Earth Science", "Biology","Calculus","Physics",
                                "History","Art","Gym"), class_id = "NULL")

## Loading the data frame into the class table
dbWriteTable(mydb, name='class', value=class.df, append= TRUE, row.names= FALSE, allow.keywords = FALSE)

## NOTE:
## Alternatively you can add multiple instances at once using the dbSendQuery command as follows:
## dbSendQuery(mydb, " INSERT INTO class VALUES ('English', NULL), ('Speech', NULL)...;)
## Make sure the order pairs are enclosed in brackets, and don't forget the semicolon at the end ;)

## Double checking our entries
dbGetQuery(mydb, "SELECT * FROM class;")

## TABLE 3, 4, & 5 - Relational databases
## Let's introduce a foreing key - a key that matches a different table for relation
dbSendQuery(mydb, "CREATE TABLE test(
        date DATE NOT NULL,
	    type ENUM('T', 'Q') NOT NULL,
	    class_id INT UNSIGNED NOT NULL,
	    test_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY);")


## Notes:
## 1) We combined the event and student id to make sure we don't have duplicate 
## scores and it makes it easier to change scores
## 2) Since neither the event or the student ids are unique on their own we are 
## able to make them unique by combining them

dbSendQuery(mydb, "CREATE TABLE score(
        student_id INT UNSIGNED NOT NULL,
	    event_id INT UNSIGNED NOT NULL,
	    score INT NOT NULL,
	    PRIMARY KEY(event_id, student_id));")

dbSendQuery(mydb, "CREATE TABLE absence(
        student_id INT UNSIGNED NOT NULL,
        date DATE NOT NULL,
        PRIMARY KEY(student_id, date));")

## We will populate these 3 tables later, let's see how we can change tables
dbSendQuery(mydb, "LOAD DATA LOCAL INFILE 'scores.txt' INTO TABLE score;")

## ----------------------------------------------------
## Manipulating Tables

## Let's add a column to the test database
## Note that we are adding a column name "maxscore" of type Integer after column "type"
dbSendQuery(mydb, "ALTER TABLE test ADD maxscore INT NOT NULL AFTER type;")

## Let's check the table again to make sure it was modified
dbGetQuery(mydb, "DESCRIBE test;")

## Let's modify the "score" table. Can you guess what this will do?
dbSendQuery(mydb, " ALTER TABLE score CHANGE event_id test_id INT UNSIGNED NOT NULL;")

## Let's populate the test table
dbSendQuery(mydb, "INSERT INTO test VALUES
            ('2014-8-25', 'Q', 15, 1, NULL),
            ('2014-8-27', 'Q', 15, 1, NULL),
            ('2014-8-29', 'T', 30, 1, NULL),
            ('2014-8-29', 'T', 30, 2, NULL),
            ('2014-8-27', 'Q', 15, 4, NULL),
            ('2014-8-29', 'T', 30, 4, NULL);")

## We can check the values in the test table to ensure it was populated
dbGetQuery(mydb, "SELECT * FROM test")

## Let's clear the score table to make sure is empty
dbSendQuery(mydb, "TRUNCATE TABLE score;")

## Let's populate the score table with a file. Just for a change!
## Note that we added that each line terminates in a newline character '\n'
dbSendQuery(mydb, "LOAD DATA LOCAL INFILE 'scores.txt' INTO TABLE score LINES TERMINATED BY '\n';")

## Let's populate the last table
dbSendQuery(mydb, "INSERT INTO absence VALUES
                (6, '2014-08-29'),
                (7, '2014-08-29'),
                (8, '2014-08-27');")

## ----------------------------------------------------
## Queries time!

## Now that we setup the database is would be nice to understand how
## to retrieve information from it.
## We already know how to get ALL the values from a table

## Let's look at selecting the first and last name from each student
## We will use the dbSendQuery command in a 3 step process
# 1) We send the query
student.query <- dbSendQuery(mydb, "SELECT FIRST_NAME, last_name FROM students;")
# 2) We fetch the query
student.names <- fetch(student.query, n=-1) # n=-1 means ALL records
# 3) We clean the pipeline
dbClearResult(student.query)

## Hint: We perform the 3 step process only when we want to retrieve data from
## the database. Another method is to use dbGetQuery

## Just for fun, what if you want to read the whole table?
classes.table <- dbReadTable(mydb, "class")

## Let's rename some of the tables
dbSendQuery(mydb, "RENAME TABLE 
            absence to absences,
            class to classes,
            score to scores,
            test to tests;")

## Remember how to check for all the tables?
dbListTables(mydb)

## Let's use dbGetQuery with an example. Follow the format of the query
## to undestand what it does
students.wa <- dbGetQuery(mydb, "SELECT first_name, last_name, state 
           FROM students
           WHERE state='WA';")
print(students.wa)

## Let's use a conditional (=, >, <. >=, <=, !=) for the YEAR()
dbGetQuery(mydb, "SELECT first_name, last_name, birth_date
            FROM students
	        WHERE YEAR(birth_date) >= 1965;")

## Let's work a bit more with conditionals operators: AND, OR, NOT
dbGetQuery(mydb, "SELECT first_name, last_name, birth_date
    FROM students WHERE MONTH(birth_date) = 2 OR state='CA';")

## Using multiple conditions
dbGetQuery(mydb, "SELECT last_name, state, birth_date
    FROM students WHERE DAY(birth_date) >= 12 && (state='CA' || state='NV');")

## Checking if values are NULL or not
dbGetQuery(mydb, "SELECT last_name FROM students WHERE last_name IS NULL;")
dbGetQuery(mydb, "SELECT last_name FROM students WHERE last_name IS NOT NULL;")

## You can order the query with the ORDER BY command
dbGetQuery(mydb, "SELECT first_name, last_name FROM students ORDER BY last_name;")
# To order in descending order use DESC
dbGetQuery(mydb, "SELECT first_name, last_name FROM students ORDER BY last_name DESC;")

## Order by different variables can also be done as follows:
dbGetQuery(mydb, "SELECT first_name, last_name, state FROM students ORDER BY state DESC, last_name ASC;")

## Limit the number of results from the query
dbGetQuery(mydb, "SELECT first_name, last_name FROM students LIMIT 5;")

## From the 5th to the 10th results
dbGetQuery(mydb, "SELECT first_name, last_name FROM students LIMIT 5, 10;")

## You can concatinate queries... Let me explain
## We will join first and last name and rename it as Name
## Similarly, join city and state (separated by ,) and rename it as Hometown
dbGetQuery(mydb, "SELECT CONCAT(first_name, ' ', last_name) AS 'Name',
                CONCAT(city, ', ', state) AS 'Hometown'
                FROM students;");

## We can match strings - let's say first name that starts with D or 
## any last name that ends in n. The % means any set of characters
dbGetQuery(mydb, "SELECT last_name, first_name FROM students
            WHERE first_name LIKE 'D%' OR last_name LIKE '%n';")

## Another way of matching single characters is by using _
dbGetQuery(mydb, "SELECT last_name, first_name FROM students WHERE first_name LIKE '___y';")

## DISTINCT eliminates duplicates - is a way of finding unique values
dbGetQuery(mydb, "SELECT DISTINCT state FROM students ORDER BY state;")

## The DISTINCT function allow us to count unique items
dbGetQuery(mydb, "SELECT COUNT(DISTINCT state) FROM students;")

## Let's do more counting
dbGetQuery(mydb, "SELECT COUNT(*) FROM students;")
dbGetQuery(mydb, "SELECT COUNT(*) FROM students WHERE sex='M';")

## GROUP BY defines how the results will be grouped
dbGetQuery(mydb, "SELECT sex, COUNT(*) FROM students GROUP BY sex;")

## Mixing COUNT, GROUP, and ORDER
dbGetQuery(mydb, "SELECT MONTH(birth_date) AS 'Month', COUNT(*) FROM students 
    GROUP BY Month ORDER BY Month;")

## HAVING allows you to narrow the results after the query is executed
## Note that we rename the count as Amount and then we use the new name with HAVING
dbGetQuery(mydb, "SELECT state, COUNT(state) AS 'Amount'
        FROM students GROUP BY state HAVING Amount > 1;")

## We can perform math operations in the queries. Let's see an example
dbGetQuery(mydb, "SELECT
        test_id AS 'Test',
    	MIN(score) AS min,
    	MAX(score) AS max,
    	MAX(score)-MIN(score) AS 'range',
    	SUM(score) AS total,
    	AVG(score) AS average
    	FROM scores
    	GROUP BY test_id;")

## Let's do another selection with a condition
dbGetQuery(mydb, "SELECT student_id, test_id
        FROM scores
        WHERE student_id = 6;")

## Wait, we are missing a test_id value. Yeah, we are missing test 3
## We can insert a new value pretty easily (we've done it before)
dbSendQuery(mydb, "INSERT INTO scores VALUES (6, 3, 24);")

## Now we have a problem, we should remove this entry from the absences table
## Let's see how we can remove the item
dbSendQuery(mydb, "DELETE FROM absences WHERE student_id = 6;")

## Let's review how we can add/modify columns in a table
dbSendQuery(mydb, "ALTER TABLE absences 
                ADD COLUMN test_taken CHAR(1) NOT NULL DEFAULT 'F'
                AFTER student_id;") 

## We can also change the data type of any of the variables
dbSendQuery(mydb, "ALTER TABLE absences
        MODIFY COLUMN test_taken ENUM('T','F') NOT NULL DEFAULT 'F';")

## Alternatively, you can change the data type using CHANGE
dbSendQuery(mydb, "ALTER TABLE absences CHANGE student_id student_id INT UNSIGNED NOT NULL;")

## You can also delete columns
dbSendQuery(mydb, "ALTER TABLE absences DROP COLUMN test_taken;")

## You can also modify existing entries with UPDATE
dbSendQuery(mydb, "UPDATE scores SET score=25 WHERE student_id=4 AND test_id=3;")

## Let's go back to do some queries. Use BETWEEN
dbGetQuery(mydb, "SELECT first_name, last_name, birth_date
    FROM students WHERE birth_date BETWEEN '1960-1-1' AND '1970-1-1';")

## We can use IN to find elements from a list
dbGetQuery(mydb, "SELECT first_name, last_name FROM students
            WHERE first_name IN ('Bobby', 'Lucy', 'Andy');")

## ----------------------------------------------------
## So far we have worked with queries that involve only one table.
## Let's work with more tables

## Join two tables by their "id". Don't forget to define the two tables
dbGetQuery(mydb, "SELECT student_id, date, score, maxscore
                FROM tests, scores
                WHERE date = '2014-08-25'
                AND tests.test_id = scores.test_id;")

## Ok so, how about listing values from a specific table. Use the "." notation
## Let's do the same query as before - pay attention to how we select items.
dbGetQuery(mydb, "SELECT scores.student_id, tests.date, scores.score, tests.maxscore
                    FROM tests, scores 
                    WHERE date = '2014-08-25'
                    AND tests.test_id = scores.test_id;")

## Let's combine more tables - Use multiple AND statements matching ids
dbGetQuery(mydb, "SELECT CONCAT(students.first_name, ' ', students.last_name) AS Name, 
                    tests.date, scores.score, tests.maxscore
                    FROM tests, scores, students
                    WHERE date = '2014-08-25'
                    AND tests.test_id = scores.test_id
                    AND scores.student_id = students.student_id;")

## The power of GROUPing! Try running the next query without the GROUP command
## Notice why it is important to have it
dbGetQuery(mydb, "SELECT students.student_id, 
                CONCAT(students.first_name, ' ', students.last_name) AS Name,
                COUNT(absences.date) AS Absences
                FROM students, absences
                WHERE students.student_id = absences.student_id
                GROUP BY students.student_id;")

## Powerful JOINs - This is just a basic introduction to JOINs
## Imagine you want to list the absences for each student, you know that not
## all students have absences. So how do we make this work? Using JOIN
dbGetQuery(mydb, "SELECT students.student_id, 
                CONCAT(students.first_name, ' ', students.last_name) AS Name,
            	COUNT(absences.date) AS Absences
            	FROM students LEFT JOIN absences
            	ON students.student_id = absences.student_id
            	GROUP BY students.student_id;")

## Note that we use LEFT JOIN to combine the table from the left with 
## elements from the table on the right (even non existing ones)

## Finally, INNER JOIN
dbGetQuery(mydb, "SELECT students.first_name, 
                    students.last_name,
                    scores.test_id,
                    scores.score
                    FROM students INNER JOIN scores
                    ON students.student_id=scores.student_id
                    WHERE scores.score <= 15
                    ORDER BY scores.test_id;")

## An INNER JOIN gets all rows of data from both tables if there
## is a match between columns in both tables

## ----------------------------------------------------
## Closing the connection
dbDisconnect(mydb)

## This is all for now, feel free to play around with more queries :)