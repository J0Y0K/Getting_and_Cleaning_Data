features = read.table("features.txt")
colnames(features) = c("label", "feature")
feature_subset = grep("mean\\(\\)|std\\(\\)", features$feature, value = T)
activity_labels = read.table("activity_labels.txt")
colnames(activity_labels) = c("label", "activity")

subject_train = read.table("train/subject_train.txt")
colnames(subject_train) = "subject"

x_train = read.table("train/X_train.txt")
colnames(x_train) = features$feature
x_train_subset = x_train[, feature_subset]

y_train = read.table("train/y_train.txt")
colnames(y_train) = "label"

train = data.frame(subject_train, x_train_subset, y_train)



subject_test = read.table("test/subject_test.txt")
colnames(subject_test ) = "subject"

x_test = read.table("test/X_test.txt")
colnames(x_test) = features$feature
x_test_subset = x_test[, feature_subset]

y_test = read.table("test/y_test.txt")
colnames(y_test) = "label"

test = data.frame(subject_test , x_test_subset, y_test)


data = rbind(train, test)
tidy_data = merge(data, activity_labels, by = "label", all = T)
tidy_data = tidy_data[, -1]
colnames(tidy_data) = gsub("\\.\\.\\.", "\\.", colnames(tidy_data)) 
colnames(tidy_data) = gsub("\\.\\.$", "", colnames(tidy_data)) 


library(reshape2)
tidy_data_melt = melt(tidy_data, id = c("subject", "activity"), measure.vars = colnames(tidy_data)[2:67])
tidy_data_melt = tidy_data_melt[order(tidy_data_melt$subject, tidy_data_melt$activity), ]
library(plyr)
tidy_data_data = ddply(tidy_data_melt, .(subject, activity, variable), summarize, mean = mean(value))
library(tidyr)
tidy_data_data_data = spread(tidy_data_data, variable, mean)
write.table(tidy_data_data_data, "tidy_data.txt", row.names = F, quote = F)