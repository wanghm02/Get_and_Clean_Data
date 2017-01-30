library(data.table)
library(reshape2)

filename<-"Dataset.zip"
## Download and unzip the dataset
if(!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# Load activity labels and features

activitylabels <- read.table("UCI HAR Dataset/activity_labels.txt") 
activitylabels[,2] <- as.character(activitylabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])


# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)

# Load the datasets
datatrain <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
datatrainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
datatrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
datatrain <- cbind(datatrainSubjects, datatrainActivities, datatrain)

datatest <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
datatestActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
datatestSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
datatest <- cbind(datatestSubjects, datatestActivities, datatest)

# merge datasets and add labels
data_all <- rbind(datatrain, datatest)
colnames(data_all) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
data_all$activity <- factor(data_all$activity, levels = activitylabels[,1], labels = activitylabels[,2])
data_all$subject <- as.factor(data_all$subject)

data_all.melted <- melt(data_all, id = c("subject", "activity"))
data_all.mean <- dcast(data_all.melted, subject + activity ~ variable, mean)

write.table(data_all.mean, "tidy.txt", row.names = FALSE, quote = FALSE)