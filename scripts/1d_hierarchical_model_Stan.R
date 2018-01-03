## One dimensional Hierarchical IRT ideal point model

library(rstan)


load("data/votes.Rda")

# take out NA for Stan:
nas <- which(is.na(m_votes))
votes <- m_votes[-nas]
N <- length(votes)
j <- rep(1:50, times = 150)
j <- j[-nas]
k <- rep(1:150, each = 50)
k <- k[-nas]
J <- max(j)
K <- max(k)

senate_data <- list(N = N, K = K, J = J, j = j, k = k, y = votes)


stan.fit <- stan(file = "models/Stan/1d_hierarchical.stan",
                 data = senate_data, iter = 5000, warmup = 2500, chains = 4, 
                 thin = 5, init = "random", verbose = TRUE, cores = 4, seed = 1234)
