library(dplyr)
library(readr)
library(sf)
library(tmap)
library(shiny)

####################################################################
#
# CS 352 (Programming Languages) Final Project
#
# This code tracks Oregon COVID data by county and outputs either an
# HTML file to be shared/embedded in a website or a gif (which I 
# find more interesting because it displays the data over time).
# 
# @author Addison Raak
# @version 1.0
# 
# April 29, 2021
#
####################################################################

# read in COVID testing data from Oregon's website
# COVID data at the county level found here: https://tinyurl.com/a7c8yrax
covidData <- readxl::read_excel("total_data.xlsx")

# rename the columns of the dataframe
names(covidData) <- c("county", "date", "total", "positive", "negative", "percent")

# changes the format of the dates to something that can be interpreted by the slider
covidData$date <- as.Date(covidData$date, format = "%b %d, %Y")

# reads in the shape file for all of the counties in Oregon
# county shapes found and parsed from here: https://www.oregon.gov/geo/Pages/census.aspx
covidMap <- st_read("counties.shp", stringsAsFactors = FALSE)

# translates the county names to fips codes so we can graph it
# county fips codes found and parsed from here: https://github.com/kjhealy/fips-codes
fipsData <- read_csv("county_fips_codes.csv")
fipsData <- fipsData %>% filter(state == "OR")
fipsData$name <- sub("([A-Za-z]+).*", "\\1", fipsData$name)
fipsData <- fipsData %>% select("fips", "name")

# clean up COVID data imported from Oregon's website, adds the name of the
# county to each row, instead of leaving them blank until the next county
for (i in 1:nrow(covidData)) {
  if (is.na(covidData[i, 1])) {
    # fills in the county name from the row above if it is NA
    covidData[i, 1] <- covidData[i - 1, 1]
  }
}

# merge the fips data with the COVID data
covidData <- inner_join(fipsData, covidData, by = c("name" = "county"))

# match data types (convert from char* to double)
covidMap$STFID <- as.double(covidMap$STFID)

# merge COVID data with shapefile
dataMap <- inner_join(covidMap, covidData, by = c("STFID" = "fips"))

# remove everything we don't need
dataMap <- dataMap %>% select("STFID", "name", "date", "positive", "geometry")

# create graph
choropleth <- tm_shape(dataMap) +
                tm_polygons("positive", id = "name", palette = "Blues",
                            title = "Positive Covid Cases By County",
                            breaks = c(0, 1, 50, 100, 300,600, 1000, 1200)) +
                tm_facets(along = "date", free.coords = FALSE)

# creates a gif of the choropleth over time
tmap_animation(choropleth, filename = "choropleth.gif",
               delay = 25, restart.delay = 2000)

###       This code is used if you want to save a map to an HTML file       ###
###    when you're running these 3 lines of code on the entire data set,    ###
### you probably can go take a nap and come back later... it takes forever. ###
###     would only recommend running this on a subset of the COVID data     ###
# tmap_mode("view")
# mapSave <- tmap_last()
# tmap_save(mapSave, "or-covid-map.html")

###  This code adds the slider to the map in a shiny app  ###
### could not get this to interact with the data properly ###
# ui <- fluidPage(
#   titlePanel("Oregon Covid Data"),
#   mainPanel(
#     tmapOutput("map")),
#     sliderInput("range", "Date", dataMap$date[1], dataMap$date[380],
#                 value = range(dataMap$date), step = 1
#   ))
# 
# server <- function(input, output) {
# 
#   filteredData <- reactive({
#     dataMap %>% filter(date >= input$date[1] & date <= input$date[2])
#   })
# 
#   output$map <- renderTmap({
#     tm_shape(dataMap) +
#       tm_polygons("positive", id = "name", palette = "Blues",
#                   title = "Positive Covid Cases By County",
#                   breaks = c(0, 1, 50, 100, 300,600, 1000, 1200)) +
#       tm_facets(along = "date", free.coords = FALSE)
#     tmap_mode("view")
#   })
# }
# 
# shinyApp(ui, server)

