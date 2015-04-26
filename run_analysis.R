library(plyr)
library(dplyr)
library(reshape2)
library(stringr)

### part 1: merging the training and the test sets 

## paths to the files inside the zip folder
## with respective file names
paths <- as.character(unzip("data/downloadedData.zip", list=T)$Name)
names(paths) <- basename(paths)

## indeces for the target files
## for both datasets
dataFilesIndices <- list(subject = c(16, 30),
                     X = c(17, 31),
                     Y = c(18, 32))

## loops over the vector paths
## extracts target files
## merges both datasets (test and train)
mergedDatasets <- list()
rounds <- 0
for(i in dataFilesIndices) {
    rounds <- rounds + 1
    # this way we add a file name collumn to the imported data
    combineDatasets <- ldply(paths[i],
                             function(x) {
                                 read.table(unz("data/downloadedData.zip", x))
                             })
    mergedDatasets[[rounds]] <- combineDatasets
}
names(mergedDatasets) <- c("subData", "xData", "yData")

dim(mergedDatasets$subdata) # 10299 obs. of 2 variables
dim(mergedDatasets$xData)   # 10299 obs. of 562 variables
dim(mergedDatasets$yData)   # 10299 obs. of 2 variables

### part 2: extracting features on the mean and standard deviation of each features

## import feature names
featuresFileIndex <- 2
featuresLabels <- ldply(paths[featuresFileIndex],
                        function(x) {
                            read.table(unz("data/downloadedData.zip", x))
                        })
names(featuresLabels) <- c("fileName", "featureNumber", "features")

subSortFeatures <- str_detect(featuresLabels$features, "mean\\(\\)|std\\(\\)")

subSetData <- mergedDatasets$xData[ , 2:ncol(mergedDatasets$xData)]
subSettData <- subSetData[ , subSettFeatures]

### part 3: use descriptive activity names

activityLabelsFileIndex <- 1
activityLabels <- ldply(paths[activityLabelsFileIndex],
                        function(x) {
                            read.table(unz("data/downloadedData.zip", x))
                        })

activityNames <- join(mergedDatasets$yData, activityLabels, by="V1")

dim(activityNames) # 10299 obs. of 4 variables

### part 4: use descriptive variable names

featureNames <- featuresLabels$features[subSetFeatures]
replacements <- list(c("\\(\\)", ""),
                     c("-", ""),
                     c("mean", "Mean"),
                     c("std", "Std"))

for(j in replacements) {
    featureNames <- str_replace_all(featureNames, j[1], j[2])
}

names(subSetData) <- featureNames

### part 5: tidy dataset with the average of each variable
tidyDataset <- cbind(subject  = mergedDatasets$subData[ , 2],
                     activity = activityNames[ , 4],
                     subSortData)

## convert data from wide to long format
tidyDataset <- melt(tidyDataset, id.vars = c("subject", "activity"))

tidyAverageValues <- tidyDataset %>%
                         group_by(subject, activity, variable) %>%
                             summarize(average = mean(value))

write.table(tidyAverageValues,
            file = "tidyAverageValues.txt",
            row.names = FALSE)
