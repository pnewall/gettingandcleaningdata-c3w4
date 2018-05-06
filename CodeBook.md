## Code Book

Code Book for the project submitted at the end of Course 3 - Getting and Cleaning Data.

### Overview

The datasets used come from this site - http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones - &
comprise detailed measurements of the physical exertions of 30 volunteers, collected by Samsung Galaxy S II smartphones worn by
the volunteers whilst they engaged in the following activities - Walking, Walking Upstairs, Walking Downstairs, Sitting, Standing
& Laying.

The overall goal of the project is to combine the various components of the test and train data & deliver two tidy datasets - one
containing detailed mean and standard deviation results, the other summarised mean results.

It is important to note that the zip file provided by the site does generate a few sub-directories.  The data preparation performed
here uses only datasets provided in the top directory & the "test" & "train" sub-directories.  It does not use any of the granular 
measurement data provided in the "Inertial Signals" directories.

### Files used (in approximate order) & assigned data frames

* activity_labels.txt -> df_alabels  - activity labels/names & id's

* y_test.txt -> df_y_test - specifies the activity id for each of the observations in X_test.txt & thus provides the means to bring 
the activity label into the final dataset(s) - 2947 observations

* y_train.txt -> df_y_train - specifies the activity id for each of the observations in X_train.txt & thus provides the means to bring 
the activity label into the final dataset(s) - 7352 observations

* X_test.txt -> df_x_test - a wide dataset, 561 columns corresponding to the detailed features or measurement types - 2947 observations

* X_train.txt -> df_x_train - a similarly wide dataset, 561 columns corresponding to the detailed features or measurement types - 7352 
observations

* features.txt -> df_flist - provides the names of the 561 features & the column headings of those which make it into the final datasets

* subject_test.txt -> df_subj_test - holds the ids of the subjects/volunteers related to each measurement in X_test.txt/df_x_test - 
2947 observations

* subject_train.txt -> df_subj_train - holds the ids of the subjects/volunteers related to each measurement in X_train.txt/df_x_train - 
7352 observations

### Process Flow

1.  Start by ensuring necessary packages available - both dplyr & reshape2 needed here

2.  Check working directory for presence of the zip file containing the datasets.  If not there, then download it.

3.  Read the necessary files into their respective data frames

4.  Merge the activity names in df_alabels into their related measurement data frames i.e df_y_test & df_y_train

5.  Use the feature names held in df_flist to set the column names of the detailed measurement data in both df_x_test & df_y_test

6.  Select from both data frames only those columns showing mean() & std()

7.  Combine/column bind for both test and train data the 3 data frames holding activity names/labels, subject ids & detailed measurements

8.  Union/row bind the test and train data & write the output file

9.  Melt the wide (68 columns) dataset from the previous step, then dcast to enable calculation of mean measurements by activity & subject

10. Write the summarised tidy output file