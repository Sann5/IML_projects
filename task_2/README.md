# Task 2
## Repository structure
```
task_2/
   ├── data/
   │     ├── train_features.csv *
   │     ├── train_labels.csv * 
   │     └── test_features.csv *
   ├── code/
   │     ├── HGBC+Lasso.ipynb
   │     ├── imputation.R
   │     └── imputation_hidden.R
   ├── output/
   └── README.md
```
## Library requirements
In order to run the code you will need the following libraries. 

### R
Our imputation script in R requires libraries `"vroom", "tidyverse", "tictoc"` and `"moments"` but the code includes comands that check for the presence of the libraries and installs them if they are missing automatically. 

### Python
```
pip install scikit-learn
pip install pandas
pip install numpy
```

## How to run the code 
In a nutshell just change the working directory so it matches the location of `task_2/data/` in your computer in `imputation.R`, run `imputation.R` and then run `HGBC+Lasso.ipynb` (for a more detailed explanation see below). Make sure that the data is available under the correct directroy as indicated above in the ropository structure. Note that the data files (marked with a star * in the scheme above) will not be included with the submission, and therefore have to be put there manually before running anything. Also make sure that you have the necesary libreries listed above. 

### 1. Imputation, feature engineering and normalisation. 

Run `imputation.R`. This will summarise the original data creating several features which are then used for the classifications and regression. **Before you do, make sure to change line 8 of the code to specify the working directory.**

```
### Set wd <- change this to match the location of the task_2 repo on your computer
setwd(dir = "address_in_your_computer/task_2/data/")
```

* **Inputs:** `data/train_features.csv`, `data/test_features.csv`. 
* **Outputs:** `data/train_features_imp.csv`, `data/test_features_imp.csv`. 

We have also provided a `imputation_hidden.R` which runs the feature transformation, imputation and normalisation for a possible hidden data set. In case you use this, you will also have to change the working directory so it matches the location of `task_2/data/` in your computer, and additionally you will have to specify the name of the input and output files in lines 11 and 12 of `imputation_hidden.R`.

```
### Define names of the files to read and to write to
file_to_read_from <- "hidden_data_file_name_here.csv"
file_to_write_to <- "hidden_data_file_name_here_imp.csv"
```

### 2. Regression and classification. 

Run `HGBC+Lasso.ipynb`. This will run the classifications in subtask 1 and 2 and the regression for subtask 3. The output will be wirten to the `output/` directory. This notebook uses some pseudo randomly generated numbers so seeds are set in place to insure the reproducibility of the results. 

* **Inputs:** `data/train_features_imp.csv`, `data/test_features_imp.csv`. 
* **Outputs:** `output/submission_HGBC_Lasso.zip`. 



