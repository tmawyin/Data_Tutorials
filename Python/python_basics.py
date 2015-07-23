''' 
Python Basics
by: Tomas Mawyin

This tutorial covers the basics of python. An introduction to
- Basic data types and variables
- Numpy and Matplotlib
- Pandas (Data frames)
- Beautiful soup

Files: playerData.csv

'''

# ----- BASICS -----
# Variable types and operations - do not need declaration
number_var = 10.0
string_var = "UTSPAN"
boolean_var = True

print (number_var + 20.5)
print "I am a member of "+ string_var
print not boolean_var

# Lists and dictionaries
list_var = [1, 4, "hello", 5.0, True]
list_var.append("world")
print list_var[2] + " " + list_var[-1]

dict_var = {"name":"Tomas", "student":True, "std_number":123456789}
print dict_var["name"]
# Get a list of dictionary keys
print(dict_var.keys())
# Get a list of dictionary values
print(dict_var.values())

# Conditionals
if boolean_var == True:
	print("The value is true!")
else:
	print("The value is false!")

# Looping
for items in list_var:
	print items

# ----- NUMPY AND MATPLOTLIB -----
import numpy as np
import matplotlib.pyplot as plt

# Dealing with arrays
array_var = np.arange(15).reshape(3, 5)
print array_var
print array_var.shape

x = np.linspace(0, 10, 100)
# Indexing
print x[:6:2]	# prints every other element from start to element number 6 (not included)
y = x**2

assert x.shape == y.shape, "Not the same shape arrays"
# Basic ploting
plt.plot(x, y, 'r--', linewidth=2.0, label="Quadratic function")
plt.legend(loc='best')
plt.grid()
plt.tight_layout()
plt.show()

# ----- PANDAS -----
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

data = pd.read_csv("playerData.csv")

# print the first 5 elements from the dataframe
print data.head()

# Selecting a specific column
data['Athlete']

# Indexing: First 5 rows
print data[:5]
print data['Athlete'][:5]

# Selecting multiple columns
print data[['Athlete','Player_Pos']]

# Most common Athletes
print data['Athlete'].value_counts()

# How can we plot the data?
data['Athlete'].plot()
data['Athlete'].value_counts().plot(kind="bar")
# plt.show()

# What if we need to select some values
isAthlete6 = data["Athlete"] == 6
isaWin = data["WinLoss"] == 1
print data[isAthlete6 & isaWin]

# More options:
# Print all columns that match the Athlete 2
print data[data['Athlete'].isin([2])]

# Counts how many in each group
print data.groupby('Athlete').size()

# Count how many items per column
print data.groupby('Athlete').count()

# ----- BEAUTIFUL SOUP -----
# This package will help us scrape the NBA standings website

from bs4 import BeautifulSoup
from urllib2 import urlopen
import numpy as np


# Helper functions
def parseCol(col):
	if len(col) == 1:
		if col[0].string == None:
			return [col[0].contents[2].strip()]
		else:
			return [col[0].string]
	else:
		if col[0].string == None:
			# We need this to grab the text from <a></a> tags
			teamName = col[0].a.string
			teamStats = [col[x].string for x in range(1,len(col))]
			teamStats.insert(0,teamName)
			return teamStats
		else:
			return [col[x].string for x in range(len(col))]



# We declare the website we want to scrape and open it
url= "http://www.nba.com/standings/team_record_comparison/conferenceNew_Std_Div.html?ls=iref:nba:gnav"
page = urlopen(url)

# Parsing through the webpage
soup = BeautifulSoup(page.read())
print soup

category = soup.find("table", {"class":"genStatTable"})
print category

# Show the table in a nice format
print category.prettify()

# Pasring through the table
records = []
# Going over every single row in the table ('tr')
for row in category.findAll('tr'):
	# Selecting the columns ('td')
    col = row.findAll('td')
    # Appending the results of the function parseCol to the "records" list
    records.append(parseCol(col))
    # Dealing with size issues
    if len(records[-1])==1:
    	records.pop(-1)

# Saving statistics to file
np.savetxt('records.csv', np.asarray(records), delimiter=",", fmt="%s")


