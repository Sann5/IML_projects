# Task 2
<<<<<<< HEAD
## Repository structure
```
task_2/
   ├── data/
   │     ├── train_features.csv *
   │     ├── train_labels.csv * 
   │     └── test_features.csv *
   ├── code/
   │     ├── previous_attempt_subtask1.ipynb
   │     ├── HGBC+Lasso.ipynb
   │     ├── preprocessing.R
   │     └── preprocessing_hidden.R
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
In a nutshell just change the working directory so it matches the location of `task_2/data/` in your computer in `preprocessing.R`, run `preprocessing.R` and then run `HGBC+Lasso.ipynb` (for a more detailed explanation see below). Make sure that the data is available under the correct directroy as indicated above in the ropository structure. Note that the data files (marked with a star * in the scheme above) will not be included with the submission, and therefore have to be put there manually before running anything. Also make sure that you have the necesary libreries listed above. 

### 1. Imputation, feature engineering and normalisation. 

Run `preprocessing.R`. This will summarise the original data creating several features which are then used for the classifications and regression. **Before you do, make sure to change line 8 of the code to specify the working directory.**

```
### Set wd <- change this to match the location of the task_2 repo on your computer
setwd(dir = "address_in_your_computer/task_2/data/")
```

* **Inputs:** `data/train_features.csv`, `data/test_features.csv`. 
* **Outputs:** `data/train_features_imp.csv`, `data/test_features_imp.csv`. 

We have also provided a `preprocessing_hidden.R` which runs the feature transformation, imputation and normalisation for a possible hidden data set. In case you use this, you will also have to change the working directory so it matches the location of `task_2/data/` in your computer, and additionally you will have to specify the name of the input and output files in lines 11 and 12 of `preprocessing_hidden.R`.

```
### Define names of the files to read and to write to
file_to_read_from <- "hidden_data_file_name_here.csv"
file_to_write_to <- "hidden_data_file_name_here_imp.csv"
```

### 2. Regression and classification. 

Run `HGBC+Lasso.ipynb`. This will run the classifications in subtask 1 and 2 and the regression for subtask 3. The output will be wirten to the `output/` directory. This notebook uses some pseudo randomly generated numbers so seeds are set in place to insure the reproducibility of the results. 

* **Inputs:** `data/train_features_imp.csv`, `data/test_features_imp.csv`. 
* **Outputs:** `output/submission_HGBC_Lasso.zip`. 

## Previous attempts
We also include the code for a different method we tried to solve the subtask 1 using Binary Relevance (`code/previous_attempt_subtask1.ipynb`). The performance was comparable to the one of our final attempt using histogram based gradient boost clasifier, but the later was 0.003 times faster. 

=======
## Subtask 1
### Multi-label classification
We need to compute for every patient the probability that the label is 1 (a test is ordered). This means that for every patient we need a real number form 0 to 1 for every posible test (inthis case we have 10 of them). This might look a little like this:

|   | test_1 | test_2 | test_3 | ... | test_10 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $patient_1$ |  0.1 |  0.4 | 1  |  ... |  0 |   |   |   |   |   |
| $patient_2 $ |   |   |   |   |   |   |   |   |   |   |
| $patient_3 $ |   |   |   |   |   |   |   |   |   |   |
| ... |   |   |   |   |   |   |   |   |   |   |
| $patient_n $ |   |   |   |   |   |   |   |   |   |   |

The true labels are in the exact same fromat but only have 1 and 0 indicating weather the patient recived the test or not. 

We need to create a model which predicts a probability each label (test) for each patient. Each label represents a different classification task, but the tasks are somehow related. 

### The predictors
The data is quite dirty:

```
# A tibble: 227,940 x 37     pid  Time   Age EtCO2   PTT   BUN Lactate  Temp   Hgb  HCO3   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl> <dbl> <dbl> <dbl> 1 26325    11    58    NA    NA   116   NA       NA  10.9    NA 2 23713     5    30    NA    NA    NA   NA       37  NA      NA 3 12026     3    30    NA    NA    NA   NA       NA  NA      NA 4 28697     6    57    NA    NA    NA   NA       37  NA      NA 5 29288     7    57    38    NA    NA    9.49    38  NA      NA 6 11285     1    37    NA    NA    NA   NA       NA  NA      NA 7 26205     3    75    NA    NA    NA   NA       37  NA      NA 8 21728     2    61    NA    NA    NA   NA       36  NA      NA 9 12993     7    56    NA    NA    NA   NA       NA  NA      NA10 20122     2    83    NA    NA    NA   NA       NA  NA      NA# … with 227,930 more rows, and 27 more variables: BaseExcess <dbl>,#   RRate <dbl>, Fibrinogen <dbl>, Phosphate <dbl>, WBC <dbl>,#   Creatinine <dbl>, PaCO2 <dbl>, AST <dbl>, FiO2 <dbl>,#   Platelets <dbl>, SaO2 <dbl>, Glucose <dbl>, ABPm <dbl>,#   Magnesium <dbl>, Potassium <dbl>, ABPd <dbl>, Calcium <dbl>,#   Alkalinephos <dbl>, SpO2 <dbl>, Bilirubin_direct <dbl>,#   Chloride <dbl>, Hct <dbl>, Heartrate <dbl>, Bilirubin_total <dbl>,#   TroponinI <dbl>, ABPs <dbl>, pH <dbl>
```

### Possible approaches
* **OneVsRest**. Decompose it into multiple independent binary classification problems (one per category). You do not consider any underlying correlation between the classes in this method. The main assumption here is that the labels are mutually exclusive. so we dont want to use this one. 
* **Binary Relevance**. An ensemble of single-label binary classifiers is trained, one for each class. Each classifier predicts either the membership or the non-membership of one class. The union of all classes that were predicted is taken as the multi-label output. This approach is popular because it is easy to implement, however it also ignores the possible correlations between class labels. **Does not work well when there’s dependencies between the labels**. OneVsRest & Binary Relevance seem very much alike. If multiple classifiers in OneVsRest answer “yes” then you are back to the binary relevance scenario (here they are not mutailly exclusive). We can use `BinaryRelevance` in `sklearn`.
* **Classifier Chains**. A chain of binary classifiers C0, C1, . . . , Cn is constructed, where a classifier Ci uses the predictions of all the classifier Cj , where j < i. This way the method, also called classifier chains (CC), can take into account label correlations. The training of the classifiers is more involved. Can use `ClassifierChain`.
* **Label Powerset** look up explanation in `LabelPowerset`.
* **Adapted Algorithm** Algorithm adaptation like k means.

### Pipeline
1. Imputation. We have to get our dirty data in to n x m dimentions where n is the number of samples (patients) and m is the number of columns. <- this for the **Binary Relevance** approach. 
2. Training
3. Testing

### Imputation
Lets try take the average of the entries that are full per patient. If there is no entries at all for that featrue in a patient we give it the median for that specific feature. 

For this I can group_by patient and feature. I crrate a function which gives me the average if at least some of the entries are not NA, if they all are it returns NA which gets assigened to the sumerised value of that patient, features combination. 

Then on a second step we take the previously computed medians of each feature and we assign it all the NA values. 

### Training
`BinaryRelevance` on `sklearn`. Make sure that the objective function is something like the F1 score which compensates for posssible class imbalance which there most certenly is. 

Implementation presents a series of subproblems:

* **Noramlizing the data.** Perhaps what we wanna do is estimate the normalize value before filling the NA with the median of each feature, becasue this way we dont affect the standarized value of the saples that do not have NA's. Hence Standarize skiping NA values and then fill the NA with the standarized version of the median.
* **Select weights to take imbalanced data into account** -> class_weight='balanced'
* **Select a kernell** Probably start with linear to avoid CV.
* **Check contiguity**. Check whether a given numpy array is C-contiguous by inspecting its flags attribute.
* **Set seed for probability estimates.**

## TODO
* check for contiguity. **done**
* make more features. **done**
* perhaps look for pralellization options to decrease runtime. **no aparent way**
* check how well the algo is doing, **done**
* if its not doing very well we can think of doing CV to optimize the parameters (kernell parameter, weights and regularization constant).
* make imputation.R run from the notebook
* checkout the format of the output and adjust accrodingly
>>>>>>> santis
