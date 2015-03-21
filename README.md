Working directory and run_analysis.R have to be in "UCI HAR Dataset" folder.

run_analysis.R does the following:
 
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

reshape2, plyr, tidyr packages have to be installed.



# Firstly set up the reference tables. Extracts only the measurements on the mean and standard deviation for each measurement.

features = read.table("features.txt")
colnames(features) = c("label", "feature")
feature_subset = grep("mean\\(\\)|std\\(\\)", features$feature, value = T)
activity_labels = read.table("activity_labels.txt")
colnames(activity_labels) = c("label", "activity")



# Secondly upload training data.

subject_train = read.table("train/subject_train.txt")
colnames(subject_train) = "subject"

x_train = read.table("train/X_train.txt")
colnames(x_train) = features$feature
x_train_subset = x_train[, feature_subset]

y_train = read.table("train/y_train.txt")
colnames(y_train) = "label"

train = data.frame(subject_train, x_train_subset, y_train)



# Thirdly upload testing data.

subject_test = read.table("test/subject_test.txt")
colnames(subject_test ) = "subject"

x_test = read.table("test/X_test.txt")
colnames(x_test) = features$feature
x_test_subset = x_test[, feature_subset]

y_test = read.table("test/y_test.txt")
colnames(y_test) = "label"

test = data.frame(subject_test , x_test_subset, y_test)



# Fourthly merges the training and the test sets to create one data set.

data = rbind(train, test)



# Fifth uses descriptive activity names to name the activities in the data set. Tidies up the variable names.

tidy_data = merge(data, activity_labels, by = "label", all = T)
tidy_data = tidy_data[, -1]
colnames(tidy_data) = gsub("\\.\\.\\.", "\\.", colnames(tidy_data)) 
colnames(tidy_data) = gsub("\\.\\.$", "", colnames(tidy_data)) 



# Sixth from the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Data is reshaped into 4 columns: subject, activity, variables, and value.

library(reshape2)
tidy_data_melt = melt(tidy_data, id = c("subject", "activity"), measure.vars = colnames(tidy_data)[2:67])
tidy_data_melt = tidy_data_melt[order(tidy_data_melt$subject, tidy_data_melt$activity), ]

## The mean is calculated for each variable for each activity and each subject.
library(plyr)
tidy_data_data = ddply(tidy_data_melt, .(subject, activity, variable), summarize, mean = mean(value))

## The mean for each variable is spread out across column. Each unique subject and activity is listed across the rows.

library(tidyr)
tidy_data_data_data = spread(tidy_data_data, variable, mean)

## Output

write.table(tidy_data_data_data, "tidy_data.txt", row.names = F, quote = F)




