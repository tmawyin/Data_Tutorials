## Tutorial - dplyr
## by Tomas Mawyin

## The importance of dplyr becomes evident in data manipulation. This tutorial will
## exploits the dplyr functions. All examples and datasets have been gathered from different sources.
library(dplyr)

## Let's do a run down of the main functions...

## Installing the data
install.packages("nycflights13")
library(nycflights13)

## The best idea is to convert the data into the "tbl_df" format. Check the class of the data
class(flights)

## Before we start, let's introduce the piping "%>%" operator, which means
## we supply an input to the operator and the output goes to the next function. Eg.
flights %>% head()

##========== FILTER() ==========
## This function allows the selection of rows in the dataframe based on a 
## filtering (logical) experssion.

## Let's filter the january 5th flights
flight.jan5 <- flights %>% filter(month == 1 & day == 5)

## Let's display the results - tbl_df shows the dataframe nicely
flight.jan5

## Exercise: get the data from either from AA (American Airlines) or the flights
## that depart from JFK
flights %>% filter(origin == 'JFK' | carrier == 'AA')

## You can also use the %in% operator: Can you guess what this will do?
flights %>% filter(carrier %in% c('AA','UA','DL'))

##========== ARRANGE() ==========
## This helps organize the data by a specific column(s)

## Let's organized the data by carrier
flights %>% arrange(carrier)

## Let'd do it in descending order - use the function (desc)
flights %>% arrange(desc(carrier))

## We can combine operators. For instance, let's filter by the 10th of January
## and order column by tail number and flight number in descending order
flights %>% filter(month == 2 & day == 10) %>% arrange(tailnum, desc(flight))

## Exercise: Arrange the flights in december by departude delay (dep_delay) and also by distance
flights %>% filter(month == 12 ) %>% arrange(dep_delay, distance)

##========== SELECT() ==========
## This function helps select specific column(s). Useful to create tidy data sets

## Let's select all columns from carrier to distance. Use a colon to select contiguous columns
flights %>% select(carrier:distance)

## How about selecting all columns except the dep_time, dep_delay, arr_time, and arr_delay
flights %>% select(-(dep_time:arr_delay))

## You can also select multiple columns - note how the order matters
flights %>% select(carrier, flight, origin, dest)

## Use 'contains' to match columns by name and also change the column name
flights %>% select(airlines = carrier, contains("dep"))

## Other helper functions you can use within select(), are starts_with(), ends_with(), and matches()
## Let's do an example where we count the number of unique airlines
flights %>% select(carrier) %>% distinct()

##========== MUTATE() ==========
## Alows to generate new columns. 
flights %>% mutate(velocity = distance/air_time, total_delay = dep_delay+arr_delay) %>% select(velocity, total_delay)

## Note how we can create columns based on already created column
flights %>% mutate(total_delay = dep_delay+arr_delay , total_time = air_time+total_delay)

##========== SUMMARISE() ==========
## Collapses a data frame to a single row.
flights %>% summarise(delay = mean(dep_time+arr_delay, na.rm = TRUE))

## You can summarize using "group_by"
flights %>% group_by(carrier) %>% summarise(delay = mean(dep_time+arr_delay, na.rm = TRUE))

## We can apply the same summary function to multiple columns at once
flights %>% group_by(carrier) %>% summarise_each(funs(mean(.,na.rm=TRUE)), dep_time, arr_time, distance)

## We can use helper functions: n() - does counting
flights %>% group_by(month, day) %>% summarise(flight_count = n()) %>% arrange(desc(flight_count))

## Another helper function is n_distinct. Can you guess what this query does?
flights %>% group_by(dest) %>% summarise(flight_count = n(), plane_count = n_distinct(tailnum))

## Other functions:
## Gettting some sample from the data
flights %>% sample_n(10)

## We can sample randomly using a fraction of rows, with replacement
flights %>% sample_frac(0.25, replace=TRUE)

