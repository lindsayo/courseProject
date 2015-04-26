## Getting and Cleaning Data
# Course Project

Full description of the raw data:
* http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Download the raw data:
* https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

The script for downloading the data is not included in ```run_analysis.R``` since it was not requested as part of the project. 

Please find below the employed function to download the raw data from the web:

~~~r
downloadData <- function(fileUrl, extension = .zip) {
    if (!file.exists("data")) dir.create("data")
    download.file(fileUrl,
                  destfile = paste("data/downloadedData", extension, sep=""),
                  method = "curl")
    dateDownloaded <<- date()
}
~~~

The proposed procedure requires the following ```R``` packages: ```plyr```,  ```dplyr```,  ```reshape2``` and ```stringr```.

If needed ```stringr``` can be replaced using ```grep``` and ```gsub```.

### Overview

The repo contains 4 files:
* ```README.md``` explains the analysis files
* ```run_analysis.R``` can be run to transform the original Samsung data in the current directory
* ```tidyAverageValues.txt``` is a **long format** tidy dataset resulting from ```run_analysis.R```
* ```codeBook.md``` describes the different variables.

The ```R``` script ```run_analysis.R``` transforms the raw data into:
* A tidy dataset
* Grouped by **feature**, **activity** and **subject**
* Summarized with the **average** value.

### 1. Merging the training and the test datasets

The first thing to do is reading the data into ```R```. Then we can merge the datasets.

In accordance with the tidy data principles it is recommended that each merged table incorporates the source. 

For that we use ```basename``` and the ```ldply``` function from the ```plyr``` package.

Each dataset contains 3 files (subjects, features and activities) to be merged independently and saved to a list.

~~~r
paths <- as.character(unzip("data/downloadedData.zip", list=T)$Name)
names(paths) <- basename(paths)

mergedDatasets <- list()
rounds <- 0
for(i in dataFilesIndices) {
    rounds <- rounds + 1
    combineDatasets <- ldply(paths[i], function(x) read.table(unz("data/downloadedData.zip", x)))
    mergedDatasets[[rounds]] <- combineDatasets
}

names(mergedDatasets) <- c("subData", "xData", "yData")
~~~

Please note above that the data is nested inside a .zip folder, thus requiring an additional connection (```unz```).

### 2. Select relevant features

We are required to extract the features on the mean and standard deviation for each measurement.

First we need to import the ```features.txt``` into ```R```. Having that we proceed  to using ```str_detect``` from ```stringr```.

From ```str_detect``` we obtain a logic vector to be used to subset our dataset.

~~~r
featuresLabels <- ldply(paths[featuresFileIndex], 
                        function(x) read.table(unz("data/downloadedData.zip", x)))

names(featuresLabels) <- c("fileName", "featureNumber", "features")

subSortFeatures <- str_detect(featuresLabels$features, "mean\\(\\)|std\\(\\)")

subSortData <- mergedDatasets$xData[ , 2:ncol(mergedDatasets$xData)]
subSortData <- subSortData[ , subSortFeatures]
~~~

Alternatively to ```str_detect```, ```grep``` from base ```R``` could be used.

### 3. Use descriptive activity names

We read ```activity_labels.txt``` into R and then ```join``` the resulting table with our dataset.

~~~r

activityLabels <- ldply(paths[activityLabelsFileIndex],
                        function(x) read.table(unz("data/downloadedData.zip", x)))

activityNames <- join(mergedDatasets$yData, activityLabels, by="V1")
~~~

### 4. Labelling the data set with descriptive variable names

The main problem with the provided names is that they contain invalid characters.

To replace invalid characters we use ```str_replace_all``` (```stringr```) but ```gsub``` from base ```R``` could be employed.

To sort relevant features we again use the logic vector obtained with ```str_detect``` above.

We use the resulting names vector to rename the features collumns in our dataset.

~~~r
featureNames <- featuresLabels$features[subSortFeatures]

replacements <- list(c("\\(\\)", ""), c("-", ""), c("mean", "Mean"), c("std", "Std"))

for(j in replacements) {
    featureNames <- str_replace_all(featureNames, j[1], j[2])
}

names(subSortData) <- featureNames
~~~

### 5. Producing the tidy dataset with the average values

The first thing the script does is convert our data from wide to long format. This is mostly a matter of personal preference.

We use the ```melt``` function from ```reshape2```.

Please note that the resulting data set remains compatible  with the principles of tidy data.

~~~r
tidyDataset <- melt(tidyDataset, id.vars = c("subject", "activity"))
~~~

Then we use the ```group_by``` and summarize functions from the ```dplyr``` package. 

This way we get our tidy data set with the **average of each variable for each activity and each subject**.

~~~r
tidyAverageValues <- tidyDataset %>%
                         group_by(subject, activity, variable) %>%
                             summarize(average = mean(value))
~~~

Finally we export the resulting dataset using ```write.table```.

~~~r
write.table(tidyAverageValues, file = "tidyAverageValues.txt", row.names = FALSE)
~~~

This final product corresponds to the  ```tidyAverageValues``` file in the repo.