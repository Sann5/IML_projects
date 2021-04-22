### Check if libraries are installed
list.of.packages <- c("vroom", "tidyverse", "tictoc", "moments")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

### Load libraries ###
library(vroom)
library(tidyverse)
library(tictoc)
library(moments)

### Set wd
setwd(dir = "/Users/santiago/ETH/2021_S/IML/IML_projects/task_2/data/")

### Define names of the files to read and to write to
file_to_read_from <- "hidden_data_file_name_here.csv"
file_to_write_to <- "hidden_data_file_name_here_imp.csv"

### Start timer
tic("Runing time")

### Load data ###
data <- vroom::vroom(file = file_to_read_from, col_types = c(col_double()))

### Make data smaller to test idea ###
#data <- data %>% filter(pid %in% 1:500)

### Make data into long format ###
data <- data %>% pivot_longer(cols = -c("pid", "Time", "Age"), 
                              names_to = "feature",
                              values_to = "values")

### Get feature distribution information to normalize the patient summery statistics###
feature_info <- data %>% 
  filter(!is.na(values)) %>% 
  group_by(feature) %>% 
  summarise(feature_median = median(values),
            feature_sd = sd(values),
            feature_mean = mean(values),
            feature_range = max(values)-min(values))

### We summarize the data with our new function, append the feature dist info, and normalize ###
data <- data %>% 
  group_by(pid, feature) %>% 
  summarise(patient_mean = mean(values, na.rm = TRUE),                          # Estimate the patient summery statistics
            patient_median = median(values, na.rm = TRUE),
            patient_min = min(values, na.rm = TRUE),
            patient_max = max(values, na.rm = TRUE),
            patient_sd = sd(values, na.rm = TRUE),
            patient_range = max(values, na.rm = TRUE)-min(values, na.rm = TRUE),
            patient_skw = skewness(values, na.rm = TRUE),
            patient_kurt = kurtosis(values, na.rm = TRUE)) %>% 
  left_join(y = feature_info,                                                   # Append to data feature statistics
            by = c("feature" = "feature")) %>% 
  mutate(norm_mean = if_else(is.nan(patient_mean), 
                             (feature_median - feature_mean) / feature_sd,      # Empty entries are given the standr. feature median.
                             (patient_mean - feature_mean) / feature_sd,
                             missing = NULL)) %>% 
  mutate(norm_median = if_else(is.na(patient_median),                     
                               (feature_median - feature_mean) / feature_sd,    # Empty entries are given the standr. feature median.
                               (patient_median - feature_median) / feature_sd,
                               missing = NULL)) %>% 
  mutate(norm_min = if_else(is.infinite(patient_min), 
                            (feature_median - feature_mean) / feature_sd,       # Empty entries are given the standr. feature median.
                            (patient_min - feature_mean) / feature_sd,
                            missing = NULL)) %>% 
  mutate(norm_max = if_else(is.infinite(patient_max),                           
                            (feature_median - feature_mean) / feature_sd,       # Empty entries are given the standr. feature median.
                            (patient_max - feature_mean) / feature_sd,
                            missing = NULL)) %>% 
  mutate(norm_sd = if_else(is.na(patient_sd), 
                           0,                                                   # Empty entries are given the 0 spread.
                           patient_sd / feature_sd,
                           missing = NULL)) %>% 
  mutate(norm_range = if_else(is.infinite(patient_range), 
                              0,                                                # Empty entries are 0 range.
                              patient_range / feature_range,
                              missing = NULL)) %>% 
  mutate(skw = if_else(is.nan(patient_skw), 
                       0,                                                       # Empty entries are 0 skw.
                       patient_skw,
                       missing = NULL)) %>% 
  mutate(kurt = if_else(is.nan(patient_kurt), 
                        0,                                                      # Empty entries are 0 kurt.
                        patient_kurt,
                        missing = NULL))

### Make data into n x m format ###
data <- data %>% 
  select(pid, feature, norm_mean, norm_median, norm_min, norm_max, norm_sd, norm_range, skw, kurt) %>% 
  pivot_wider(id_cols = pid,
              names_from = feature,
              values_from = c(norm_mean, norm_median, norm_min, norm_max, norm_sd, norm_range, skw, kurt))

### Write data to output ###
vroom_write(data, path = file_to_write_to, delim = ",")

toc()
