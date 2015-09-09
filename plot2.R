##Calculate how much memory dataset will requre: 2,075,259 rows x 9 columns x 8 bytes x 2 overhead / 1,000,000 bytes= 300MB
#Look at data, read first 100 rows: data <- read.table("household_power_consumption.txt", sep = ";", header=TRUE, nrows = 100, na.strings = "?")

#read only requered rows with sql query, the data from the dates 2007-02-01 and 2007-02-02
#another approach would be to read whole dataset with fread for data.tables, and then subset

library(sqldf)
df <- read.csv.sql("household_power_consumption.txt", sep = ";", sql = "select * from file where Date = '1/2/2007' or Date = '2/2/2007'")

#convert variable names to lower cases(optional)
names(df) <- tolower(names(df))

#check in which rows the values are "?"
##test <- data.frame(x = c(1,3,5,"?",56), y = c(4,"?",5,"?",7))
check <- sapply(df, function(x){grep("\\?", x)})

#change "?" to NA
df[df == "?"] <- NA

#check wwhich rows have NAs
df_bad <- df[!complete.cases(df), ]

#remove NAs
df <- df[complete.cases(df), ]

#convert the Date and Time variables to Date/Time classes
library(lubridate)
df$date <- dmy(df$date)

timestamp <- paste(df$date, sep = " ", df$time)
df$time <- ymd_hms(timestamp)

#build plot
with(df, plot(time, global_active_power, type = "l", col= "sienna", ylab = "Global Active Power (kilowatts)", xlab = ""))

#copy plot to png file (default is 480x480)
dev.copy(png, file = "plot2.png")
dev.off()


        
