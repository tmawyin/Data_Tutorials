from bs4 import BeautifulSoup
import scraperwiki as sw
import urllib2
import numpy as np

# Website address
url = "http://www.worldrowing.com/assets/pdfs/ECH_2015/ROM121101_MGPS.pdf"

# Opening the url
urlFile = urllib2.urlopen(url)

# Reading the file
urlRead = urlFile.read()

# Translate the pdf to xml file
xmlFile = sw.pdftoxml(urlRead)

# Now we can use BeautifulSoup to read the xml file (same as an html)
xml = BeautifulSoup(xmlFile,'xml')
# print xml.prettify()

''' Note: This requires a bit of information from the xml file, 
    so you need to look at the xml file. You can get an idea by
    uncommenting the previous line, i.e., print xml.prettify()
'''
# First we will get the table data - we get all the table stats based on formatting
tableData = xml.findAll("text",{"font":"7","height":"11"})
statsData = []
# The variable "values" will take into account any other data that is not part of the table but follows a similar format
values = int(round(len(tableData)/13))

# We get all the stats data in a loop
for i in range(values):
	temp = [stat.text for stat in tableData[i*13:i*13+13]]
	statsData.append(temp)

# Generating the headers
teamList = []
tempList = xml.findAll("text",{"font":"2","height":"14"})
for item in tempList:
	if len(item.text) == 3:
		teamList.append(item.text)

header = ["distance"]
for value in teamList:
	header.append(value+"_speed")
	header.append(value+"_stroke")

statsData.insert(0,header)
# print statsData

# Saving to csv file
np.savetxt('dataFile1.csv', np.asarray(statsData), delimiter=",", fmt="%s")



