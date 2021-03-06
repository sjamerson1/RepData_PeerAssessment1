## LOADING AND PROCESSING DATA
unzip(zipfile="repdata_data_activity.zip")
data <- read.csv("activity.csv", header = TRUE, sep = ',', colClasses = c("numeric", "character",
                                                                          "integer"))
## Cleaning the data
data$date <- ymd(data$date)

## WHAT IS THE MEAN TOTAL NUMBER OF STEPS TAKEN PER DAY
steps <- data %>%
  filter(!is.na(steps)) %>%
  group_by(date) %>%
  summarize(steps = sum(steps)) %>%
  print

## Historgram of Steps
ggplot(steps, aes(x = steps)) +
  geom_histogram(fill = "firebrick", binwidth = 1000) +
  labs(title = "Histogram of Steps per Day", x = "Steps per Day", y = "Frequency")
print

## Calculate the mean and median of the total number of steps taken per day
mean_steps <- mean(steps$steps, na.rm = TRUE)
median_steps <- median(steps$steps, na.rm = TRUE)

## WHAT IS THE AVERAGE DAILY ACTIVITY PATTERN
averages[which.max(averages$steps),]

interval <- data %>%
  filter(!is.na(steps)) %>%
  group_by(interval) %>%
  summarize(steps = mean(steps))
interval[which.max(interval$steps),]

##IMPUTING MISSING VALUES
## Summarize the missing values
sum(is.na(data$steps))

## Fill in the missing NA data with the average number of steps in the same 5 min interval
##create a new dataset
data_full <- data
nas <- is.na(data_full$steps)
avg_interval <- tapply(data_full$steps, data_full$interval, mean, na.rm=TRUE, simplify=TRUE)
data_full$steps[nas] <- avg_interval[as.character(data_full$interval[nas])]

## Check for any missing
sum(is.na(data_full$steps))


steps_full <- data_full %>%
  filter(!is.na(steps)) %>%
  group_by(date) %>%
  summarize(steps = sum(steps)) %>%
  print

## Historgram of total number of steps taken each day
ggplot(steps_full, aes(x = steps)) +
  geom_histogram(fill = "firebrick", binwidth = 1000) +
  labs(title = "Histogram of Steps per day, including missing values", x = "Steps per day", y = "Frequency")
print

## Calculate the mean and median total number of steps taken per day
mean_steps_full <- mean(steps_full$steps, na.rm = TRUE)
median_steps_full <- median(steps_full$steps, na.rm = TRUE)

## ARE THERE DIFFERENCES IN ACTIVITY PATTERNS BETWEEN WEEKDAYS AND WEEKENDS
## Create new factor variable in data set week type
data_full <- mutate(data_full, weektype = ifelse(weekdays(data_full$date) == "Saturday" | weekdays(data_full$date) == "Sunday", "weekend", "weekday"))
data_full$weektype <- as.factor(data_full$weektype)

## Panel Plot containing a time series plot
interval_full <- data_full %>%
  group_by(interval, weektype) %>%
  summarise(steps = mean(steps))
s <- ggplot(interval_full, aes(x=interval, y=steps, color = weektype)) +
  geom_line() +
  facet_wrap(~weektype, ncol = 1, nrow=2)
print(s)
