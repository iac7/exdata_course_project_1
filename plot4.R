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
# mar are sets around each figure, and oma (outer margins) is default 0, for more info see http://research.stowers-institute.org/mcm/efg/R/Graphics/Basics/mar-oma/index.htm
par(mfrow = c(2,2), cex.lab = 0.7, cex.axis = 0.7, mar = c(4, 4, 1, 1))
with(df, {
        plot(time, global_active_power, xlab = "", ylab = "Global Active Power", type = "l")
        plot(time, voltage, xlab = "datetime", ylab = "Voltage", type ="l")
        plot(time, sub_metering_1, type = "l", xlab = "", ylab = "Energy sub metering")
        with (df, points(time, sub_metering_2, type ="l", col = "red"))
        with (df, points(time, sub_metering_3, type = "l", col = "blue"))
        legend("topright", lty = 1, col = c("black", "red", "blue"), legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), cex = 0.7, x.intersp = 0.5, y.intersp = 0.5, bty ="n")
        plot(time, global_reactive_power, type="l", col="violet", xlab = "datetime")
})


#copy plot to png file (default is 480x480)
dev.copy(png, file = "plot4.png")
dev.off()


        
