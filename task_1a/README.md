# Task 1a. Cross-validation for ridge regression
## Santi's take
### Overview of the algorithm
1. Split data randomly into 10 equal parts. We have 150 observations so each group will have 15 observations (rows).
2. For fold 1 train the model (either gradietn decent of closed form, maybe we should try a submission with both) with other 9 folds and validate the model (estimate the RMSE) on the 1st fold. 
3. Do this for every value of $\lambda_i$. By estimating the RMSE for every lambda with the same subset of the data (the same fold) we avoid bias due to the sampling of the observations in the k-folds. 
4. Do this for every fold. 

The result of all of these computation should yield something like this. 

|   | 1st | 2nd | 3rd | 4th | 5th | 6th | 7th | 8th | 9th |10th | average|
|---|---|---|---|---|---|---|---|---|---|---|---|
| $\lambda_1$ |   |   |   |   |   |   |   |   |   |   |
| $\lambda_2$ |   |   |   |   |   |   |   |   |   |   |
| $\lambda_3$ |   |   |   |   |   |   |   |   |   |   |
| $\lambda_4$ |   |   |   |   |   |   |   |   |   |   |
| $\lambda_5$ |   |   |   |   |   |   |   |   |   |   |

Every entrie is the RMSE of that specific validation fold (columns) with a specific $\lambda$. The submission file should be the `average` column in the right of the table.

$$
\begin{align}
\textrm{Average} = \frac {\sum_{j=1}^{10} \textrm{RMSE}_j}{10} = \frac {\sum_{j=1}^{10} \sqrt{\frac{1}{n} \sum_{i=1}^{n} (y_i - \hat{y}_i)^2}_j}{10}
\end{align}
$$

### Closed form solution, ridge regression
$$
\hat{w} = \big(X^T X + \lambda I \big)^{-1} X^T y 
$$

Upon a first inspection the X matrix has proven to have independent coluns which means we can apply a more direct method to compute the closed form solution (without the pseudo inverses).

### Gradeint decent, ridge regression
$$
\begin{align}
\nabla \bigg( \frac{1}{n} \sum_{i=1}^n (y_1 - w^Tx_i)^2 + \lambda||w||_2^2 \bigg) = \nabla \hat{R}(w) + \lambda ||w||_2^2
\end{align}
$$

Such that...
$$
\begin{align}
w_{t=1} = w_t - \eta \big( \nabla \hat{R}(w_t) + 2 \lambda w_t \big) = (1-2\lambda\eta_t)w_t - \eta_t\nabla_w \hat{R}(w_t))
\end{align}
$$

*These equations should be cheked*