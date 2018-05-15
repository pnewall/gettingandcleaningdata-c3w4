#
# start by ensuring necessary packages available\
#

if (!"dplyr" %in% installed.packages()) {
	install.packages("dplyr")
}
library(dplyr)

if (!"reshape2" %in% installed.packages()) {
	install.packages("reshape2")
}
library(reshape2)

#
# get local copy of dataset
#

print("preparing input file ...")
fileName <- "./c3w4.zip"
fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists(fileName)) {
    download.file(fileUrl, "./c3w4.zip", method = "curl")
}

#
# set up data frames for subsequent merging etc
#

print("reading input file ...")

df_alabels <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/activity_labels.txt"), header = FALSE, sep = "")

df_y_test <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/test/y_test.txt"), header = FALSE, sep = "")

df_y_train <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/train/y_train.txt"), header = FALSE, sep = "")

df_x_test <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/test/X_test.txt"), header = FALSE, sep = "")

df_x_train <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/train/X_train.txt"), header = FALSE, sep = "")

df_flist <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/features.txt"), header = FALSE, sep = "")

df_subj_test <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/test/subject_test.txt"), header = FALSE, sep = "")

df_subj_train <- read.table(unz("./c3w4.zip", "UCI HAR Dataset/train/subject_train.txt"), header = FALSE, sep = "")

#
# set up column names to enable merging
#

print("building combined test and train dataset ...")
df_alabels <- rename(df_alabels, activity_id = V1, activity_name = V2)
df_y_test <- rename(df_y_test, activity_id = V1)
df_y_train <- rename(df_y_train, activity_id = V1)

#
# merge the data frames holding activity id's & labels
#
# meets requirement 3. Uses descriptive activity names to name the activities in the data set
#

df_y_test_alabels <- merge(x = df_y_test, y = df_alabels, by.x = "activity_id", by.y = "activity_id")
df_y_train_alabels <- merge(x = df_y_train, y = df_alabels, by.x = "activity_id", by.y = "activity_id")

#
# now that we have descriptive activity names & activity_id column not need for requirement 5, de-select it
#

df_y_test_alabels <- select(df_y_test_alabels, -activity_id)
df_y_train_alabels <- select(df_y_train_alabels, -activity_id)

#
# set the column names of the 2 x-files
#
# meets requirement 4. Appropriately labels the data set with descriptive variable names
#

colnames(df_x_test) <- df_flist[, 2]
colnames(df_x_train) <- df_flist[, 2]

#
# select only columns showing mean() & std() - !duplicated because some
# feature names e.g fBodyAcc-bandsEnergy()-1 appear multiple times & regex
# expression has to be sure to pick up only features containing "-mean()" &
# "-std()" rather than any containing "-meanFreq()" etc
#
# meets requirement 2. Extracts only the measurements on the mean and standard deviation for each measurement.
#

df_x_test_sm <- select(df_x_test[, !duplicated(colnames(df_x_test))], matches("mean[(][)]|std[(][)]"))
df_x_train_sm <- select(df_x_train[, !duplicated(colnames(df_x_train))], matches("mean[(][)]|std[(][)]"))

#
# column bind/combine subjects, activities, mean() & std() measurements for test & train data
#

df_test_all <- cbind(df_y_test_alabels, df_subj_test, df_x_test_sm)
df_train_all <- cbind(df_y_train_alabels, df_subj_train, df_x_train_sm)

#
# row bind/union the last two data frames & rename V1 column to subject_id\
# then write first tidy dataset out to file
#
# meets requirement 1. Merges the training and the test sets to create one data set.
#

print("finalising combined dataset ...")
df_all <- rbind(df_test_all, df_train_all)
df_all <- rename(df_all, subject_id = V1)
write.table(df_all, file = "./tidy_measures.txt", sep = ",", row.names = FALSE)

#
# df_all is wide (68 variables) so melt by activity_name & subject_id, then dcast with mean function
# to meet requirement 5. a second, independent tidy data set with the average of each variable for
# each activity and each subject
#

print("building second tidy dataset ...")
df_all_melt <- melt(df_all, id.vars = c("activity_name", "subject_id"), variable.name = "measurement_type")
df_all_cast <- dcast(df_all_melt, subject_id + activity_name ~ measurement_type, mean, value.var = "value")
write.table(df_all_cast, file = "./tidy_means.txt", sep = ",", row.names = FALSE)
print("done.")