# Oregon COVID Visualizer by County

This code tracks Oregon COVID-19 data by county and outputs either an HTML file (to be shared or embedded onto a website or a gif. I added the code to create the gif just to see what it would produce, but I ended up finding it more interesting than the HTML file because it shows the data over time.

I retrieved the daily Oregon COVID testing data (broken down by county) here: https://tinyurl.com/a7c8yrax
And the shapefile data here: https://www.oregon.gov/geo/Pages/census.aspx
fips codes found here: https://github.com/kjhealy/fips-codes

The shapefiles are not labeled by the name of each county, but rather use fips codes, so a dataframe containing the name of the county with its corresponding fips code was necessary to merge the COVID testing data with the shapefile.

File Breakdown:
- oregon_county_covid_tracker.R
  - Source Code

- total_data.xlsx
  - Oregon COVID-19 data at the county level for each day from 03/28/2020 until the date the file was downloaded

- county_fips_codes.csv
  - CSV file containing the codes for each county used to match the covidData data frame to the shapes in the shapefile (which did not have county names, only county codes)

- counties.shp
  - This is the shapefile that countained the spatial information about each county in order to plot the data onto the right areas of the map

- or-covid-map.html
  - HTML output file. This contains the interactive map that was demonstrated in the presentation. Allows the user to click on each county to see the na,e and number of cases over a given time period or single day (specified during the generation of the HTML file).

- choropleth.gif
  - GIF output file. A gif that iterates over each date in the total_data.xlsx file. Shows how the number of positive cases per day changed over time.

# GIF Output
<p align="center">
  <img src="choropleth.gif" alt="animated" />
</p>
