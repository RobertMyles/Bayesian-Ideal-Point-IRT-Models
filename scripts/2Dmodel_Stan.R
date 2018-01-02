# Two-Dimensional IRT ideal point model, with vote parameters (Beta) used as 
# identifying constraints as per Simon Jackman ("Multidimensional analysis of 
# roll call data via Bayesian simulation: identification, estimation, inference, 
# and model checking", Political Analysis, Vol 9, Issue 3, 2001).
library(rstan)

# data:
load("data/votes.Rda")


# take out NA:
nas <- which(is.na(m_votes))
votes <- m_votes[-nas]
N <- length(votes)
j <- rep(1:50, times = 150)
j <- j[-nas]
k <- rep(1:150, each = 50)
k <- k[-nas]
J <- max(j)
K <- max(k)


stan.data <- list(J = J, K = K, N = N, j = j, k = k, y = votes, D = 2)

# Stan run:
stan.fit <- stan("models/Stan/2d_model.stan", 
                 data = stan.data, iter = 5000, warmup = 2500, 
                 chains = 4, verbose = TRUE, cores = 4, seed = 1234)
