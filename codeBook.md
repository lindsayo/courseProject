# Codebook

### Introduction

The raw data is inside a ```.zip``` file named ```downloadedData.zip```.

This file is place inside a ```data``` folder using the download script in ```README.md```.

### Variables

* ```paths``` contains the full names for the contents of the ```.zip``` file
* ```dataFilesInidices```, ```featuresFileIndex``` and ```activityLabelsFileIndex``` contain indices to ```paths```
* ```mergedDatasets```is a list containing 3 data frames (subject data, features data and activities data)
* ```rounds``` is used to save each merged data frame to ```mergedDatasets```
* ```combineDatasets``` merges data from the train and test data sets using ```ldply``` so we preserve original file 
names
* ```featuresLabels```, ```activityLabels``` contain names from ```features.txt``` and ```activity_labels.txt```
* ```subSetFeatures``` is a logic vector indicating ```featuresLabels``` that contain measures on the ```mean``` or ```std```
* ```subSetData``` is the data frame resulting from passing ```subSetFeatures``` to the collumns of features data
* ```activityNames``` is a data frame resulting from the ```join``` between activities data and respective ```activityLabels```
* ```featureNames``` results from passing ```subSetFeatures``` to ```featuresLabels``` and ```str_replace_all``` 
invalid characters
* ```featureNames``` is used to rename the collumns of ```subSetData```
* the names in ```featureNames``` are considered to be descriptive
* ```tidyDataset``` ```cbinds``` subject id, activities labels and ```subSetData``` into a single data frame
* ```tidyDataset``` is in long format
* ```tidyAverageValues``` is our ```tidyDataset``` ```grouped_by``` subject, activity and variable
* ```tidyAverageValues``` is ```summarized``` with the average. 

### About the script
