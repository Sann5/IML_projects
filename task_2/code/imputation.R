### Load libraries ###
library(vroom)
library(tidyverse)
library(tictoc)

### Start timer
tic("Runing time")

### Load data ###
data <- vroom::vroom(file = "/Users/santiago/ETH/2021_S/IML/IML_projects/task_2/task2_k49am2lqi/train_features.csv",
                     col_types = c(col_double()))

### Make data samller to test idea ###
#data <- data %>% filter(pid %in% 1:500)

### Make data into long format ###
data <- data %>% pivot_longer(cols = -c("pid", "Time", "Age"), 
                      names_to = "feature",
                      values_to = "values")

### Get feature distribution information ###
feature_info <- data %>% 
  filter(!is.na(values)) %>% 
  group_by(feature) %>% 
  summarise(feature_median = median(values),
            feature_sd = sd(values),
            feature_mean = mean(values))

### We summarize the data with our new function, append the feature dist info, and normalize ###
data <- data %>% 
  group_by(pid, feature) %>% 
  summarise(patient_mean = mean(values, na.rm = TRUE),
            patient_median = median(values, na.rm = TRUE),
            patient_min = min(values, na.rm = TRUE),
            patient_max = max(values, na.rm = TRUE),
            patient_sd = sd(values, na.rm = TRUE)) %>% 
  left_join(y = feature_info,
            by = c("feature" = "feature")) %>% 
  mutate(norm_mean = if_else(is.nan(patient_mean), 
                            (feature_median - feature_mean) / feature_sd,
                            (patient_mean - feature_mean) / feature_sd,
                             missing = NULL)) %>% 
  mutate(norm_median = if_else(is.na(patient_median), 
                              (feature_median - feature_mean) / feature_sd,
                              (patient_median - feature_mean) / feature_sd,
                               missing = NULL)) %>% 
  mutate(norm_min = if_else(is.infinite(patient_min), 
                           (feature_median - feature_mean) / feature_sd,
                           (patient_min - feature_mean) / feature_sd,
                            missing = NULL)) %>% 
  mutate(norm_max = if_else(is.infinite(patient_max), 
                           (feature_median - feature_mean) / feature_sd,
                           (patient_max - feature_mean) / feature_sd,
                            missing = NULL)) %>% 
  mutate(norm_sd = if_else(is.na(patient_sd), 
                           1,
                           patient_sd / feature_sd,
                           missing = NULL))
  
### Make data into n x m format ###
data <- data %>% 
  select(pid, feature, norm_mean, norm_median, norm_min, norm_max, norm_sd) %>% 
  pivot_wider(names_from = feature,
              values_from = c(norm_mean, norm_median, norm_min, norm_max, norm_sd))

### Write data to output ###
vroom_write(data, 
            path = "/Users/santiago/ETH/2021_S/IML/IML_projects/task_2/data/train_features_imp.csv",
            delim = ",")

toc()
