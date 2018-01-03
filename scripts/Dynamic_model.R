## Dynamic one dimensional IRT ideal point model

library(rstan)


load("data/votes.Rda")
load("data/votes_data.Rda")

votes_data <- mutate(votes_data, year_index = ifelse(year == "2017", 1, 2))
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
t <- rep(1:2, each = N/2)
T <- 2

stan_data <- list(N = N, K = K, J = J, j = j, k = k, t = t, T = T, y = votes)


dyn_fit <- stan("models/Stan/dynamic_model.stan", 
                data = stan_data, iter = 5000, warmup = 2500, 
                thin = 5, chains = 4, seed = 1234, cores = 4)

