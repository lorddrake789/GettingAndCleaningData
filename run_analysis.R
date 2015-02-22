SubjectTrain <- as.data.table(read.table(file.path("./train/subject_train.txt")))
SubjectTest <- as.data.table(read.table(file.path("./test/subject_test.txt")))
ActivityTrain <- as.data.table(read.table(file.path("./train/Y_train.txt")))
ActivityTest <- as.data.table(read.table(file.path("./test/Y_test.txt")))

fileToDataTable <- function (f) {
    df <- read.table(f)
    dt <- data.table(df)
}


Train <- as.data.table(fileToDataTable(file.path("./train/X_train.txt")))
Test  <- as.data.table(fileToDataTable(file.path("./test/X_test.txt" )))

MergedSubject <- rbind(SubjectTrain, SubjectTest)
setnames(MergedSubject, "V1", "subject")

MergedActivity <- rbind(ActivityTrain, ActivityTest)
setnames(MergedActivity, "V1", "ActivityNumber")

MergedData <- rbind(Train, Test)

MergedSubject <- cbind(MergedSubject, MergedActivity)
MergedData <- cbind(MergedSubject, MergedData)

setkey(MergedData, subject, activity)

Features <- read.table(file.path("./features.txt"))

setnames(Features, names(Features), c("FeatureNumber", "FeatureName"))

SubsetFeatures <- subset(Features, grepl('-(mean|std)\\(', Features$FeatureName))

SubsetFeatures$FeatureCode <- sub("^", "V", SubsetFeatures$FeatureCode)
SelectData <- c(key(MergedData), SubsetFeatures$FeatureCode)
MergedData <- MergedData[, SelectData, with = FALSE]

ActivityNames <- as.data.table(read.table(file.path("./activity_labels.txt")))
setnames(ActivityNames, names(ActivityNames), c("ActivityNumber", "ActivityName"))

MergedData <- merge(MergedData2, ActivityNames, by = "ActivityNumber", all.x = TRUE)
setkey(MergedData, subject, ActivityNumber, ActivityName)
MergedData <- data.table(melt(MergedData, key(MergedData), variable.name = "FeatureCode"))

setwd('..')
write.csv(MergedData, file = 'tidy_data.csv', row.names = FALSE)