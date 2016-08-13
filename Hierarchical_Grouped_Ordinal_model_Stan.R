rm(list=ls())
library(rstan)
library(dplyr)
library(readr)

# This example shows an Ordinal One-Dimensional IRT Ideal Point model. The ideal points are also hierarchical, being grouped by party.


VoteData  <-  read_csv("https://github.com/RobertMyles/R-Scripts-Bayesian-Ideal-Point-IRT/blob/master/Senate_Example.csv?raw=true")
VoteData <- VoteData %>% 
  mutate(Vote = ifelse(Vote=="S", 1, ifelse(Vote=="N", 0, 9))) %>% 
  mutate(Vote = as.numeric(Vote)) %>% 
  mutate(SenIndex = as.numeric(as.factor(SenatorUpper))) %>% 
  mutate(VoteIndex = as.numeric(as.factor(VoteNumber))) %>%
  mutate(PartyIndex = as.numeric(as.factor(Party))) %>%
  filter(Vote != 9)


# Data for Stan
senate_data <- list(N=nrow(VoteData), K=max(VoteData$SenIndex),
                    J=max(VoteData$SenIndex),
                    y=VoteData$Vote, k=VoteData$SenIndex, 
                    j=VoteData$SenIndex, Party=VoteData$PartyIndex,
                    p=2)


ordinal_model <- "
functions {
  vector gpcm_probs(real theta, real alpha, vector beta) {
  vector[rows(beta) + 1] unsummed;
  vector[rows(beta) + 1] probs;
  unsummed = append_row(rep_vector(0.0, 1), alpha*theta - beta);
  probs = softmax(cumulative_sum(unsummed));
  return probs;
}
}
data {
  int<lower=1> J;         //Legislators
  int<lower=1> K;         //Proposals
  int<lower=1> N;         //no. of observations
  int<lower=0> y[N];      // response for n; y = 0, 1 ... m_i
  int<lower=0> j[N];      //Legislator for observation n
  int<lower=0> k[N];      //Proposal for observation n
  int<lower=0> p;         // number of predictors
  int<lower=1> Party[N];  // Party for observation N
}
transformed data {
  int r[N];                      // modified response; r = 1, 2, ... m_i + 1
  int m[K];                      // # parameters per item
  int pos[K];                    // first position in beta vector for item
  m = rep_array(0, K);
  for(n in 1:N) {
  r[n] = y[n] + 1;
  if(y[n] > m[k[n]]) m[k[n]] = y[n];
  }
  pos[1] = 1;
  for(i in 2:(K))
  pos[i] = m[i-1] + pos[i-1];
}
parameters {
  vector[K] alpha;
  vector[sum(m)-1] beta_free;    // unconstrained item parameters
  vector[J] theta;
  vector[J] mu_theta;
  real gamma[p];                 // predictors
}
transformed parameters {
vector[sum(m)] beta;           // constrained item parameters
beta = append_row(beta_free, rep_vector(-1*sum(beta_free), 1));
}
model {
  for (z in 1:J)
  theta ~ normal(0, 1);
  for (i in 1:J){
  theta[i] ~ normal(mu_theta[i], 1);
  mu_theta[i] ~ normal(gamma[1] + gamma[2]*Party[i], 1);
  }
  alpha ~ normal(0, 1);
  beta_free ~ normal(0, 5);
  for (n in 1:N)
  r[n] ~ categorical(gpcm_probs(theta[j[n]], alpha[k[n]],
  segment(beta, pos[k[n]], m[k[n]])));
}"


stan.fit <- stan(model_code = ordinal_model, data=senate_data, iter=5000, 
                  warmup=2500, thin=5, chains=4, seed=1234, cores=4)

