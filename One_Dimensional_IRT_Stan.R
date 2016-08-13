## One dimensional IRT ideal point model, using Stan in R

library(rstan)
library(dplyr)
library(readr)

# This example shows a One-Dimensional IRT Ideal Point model. For higher dimensions, see Multidimensional_IRT_Stan.R


VoteData  <-  read_csv("https://github.com/RobertMyles/R-Scripts-Bayesian-Ideal-Point-IRT/blob/master/Senate_Example.csv?raw=true")
VoteData <- VoteData %>% 
  mutate(Vote = ifelse(Vote=="S", 1, ifelse(Vote=="N", 0, 9))) %>% 
  mutate(Vote = as.numeric(Vote)) %>% 
  mutate(SenIndex = as.numeric(as.factor(SenatorUpper))) %>% 
  mutate(VoteIndex = as.numeric(as.factor(VoteNumber))) %>% 
  filter(Vote != 9)


senate_data <- list(N=nrow(VoteData), K=max(VoteData$SenIndex),
                    J=max(VoteData$SenIndex),
                    y=VoteData$Vote, k=VoteData$SenIndex, 
                    j=VoteData$SenIndex, D=2)



stan.code <- "
data {
  int<lower=1> J; //Senators
  int<lower=1> K; //Proposals
  int<lower=1> N; //no. of observations
  int<lower=1, upper=J> j[N]; //Senator for observation n
  int<lower=1, upper=K> k[N]; //proposal for observation n
  int<lower=0, upper=1> y[N]; //vote of observation n
}
parameters {
  real alpha[K];
  vector[K] beta;
  vector[J] theta;
}
model {
  alpha ~ normal(0,10); 
  beta ~ normal(0,10); 
  theta ~ normal(0,1); 
  theta[1] ~  normal(1, .01);
  theta[2] ~ normal(-1, .01);  
  for (n in 1:N)
  y[n] ~ bernoulli_logit(theta[j[n]] * beta[k[n]] - alpha[k[n]]);
}"

stan.fit <- stan(model_code=stan.code, data=senate_data, iter=5000, warmup=2500, chains=4, thin=5, init="random", verbose=TRUE, cores=4, seed=1234)

