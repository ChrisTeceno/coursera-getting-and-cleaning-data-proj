# this script will: 
# get data
# merge training and test sets
# extract only the mean and std
# rename activities
# label variables
# create a new tidy set

## libraries needed for melt and cast
library(reshape2)
library(reshape)

## get data
filename <- "project_data.zip"

## download data if it does not exist
if (!file.exists(filename)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,filename, method = "curl")
}

## unzip if not unzipped
if (!file.exists("UCI HAR Dataset")){
  unzip(filename)
}

## get activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")

## get feature labels
features <- read.table("UCI HAR Dataset/features.txt")

## select features with mean and std (except "meanFreq")
features_wanted <-intersect(grep(".*mean.*|.*std.*", features[,2]), 
                            grep(".*meanFreq.*", features[,2], invert = TRUE))

## get names of features
features_wanted.names <-features[features_wanted,2]
## swap the "-" for "_"
features_wanted.names <- gsub('-', '_', features_wanted.names)
## remove "()"
features_wanted.names <- gsub('[()]', '', features_wanted.names)

## load train data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_wanted]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

## load test data
test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_wanted]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

## merge rows
all_data <- rbind(train, test)
## rename cols
colnames(all_data) <- c("subject", "activity", features_wanted.names)

# relabel activities and make both activities and subjects as factors
all_data$activity <- factor(all_data$activity, levels = activity_labels[,1], labels = activity_labels[,2])
all_data$subject <- as.factor(all_data$subject)

## melt the data
all_data.melted <- melt(all_data, id = c("subject", "activity"))

## cast into a tidy dataset
tidy_data <- dcast(all_data.melted, subject + activity ~ variable, mean)

write.table(tidy_data, "tidy_data.txt", row.names = FALSE)


