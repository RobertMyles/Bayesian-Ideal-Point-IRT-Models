## Dynamic one dimensional IRT ideal point model, using Stan in R
rm(list=ls())
library(rstan)
library(dplyr)
library(readr)
library(stringr)

#This model can be very computationally expensive...you have been warned!

VoteData  <-  read_csv("https://github.com/RobertMyles/R-Scripts-Bayesian-Ideal-Point-IRT/blob/master/Senate_Example.csv?raw=true")
VoteData <- VoteData %>% 
  mutate(Vote = ifelse(Vote=="S", 1, ifelse(Vote=="N", 0, 9))) %>% 
  mutate(Vote = as.numeric(Vote)) %>% 
  mutate(SenIndex = as.numeric(as.factor(SenatorUpper))) %>% 
  mutate(VoteIndex = as.numeric(as.factor(VoteNumber))) %>%
  mutate(Year = unlist(str_extract_all(VoteNumber, "[0-9]{4}"))) %>%
  mutate(YearIndex = as.numeric(as.factor(Year))) %>%
  filter(Vote != 9)


# Data for Stan

stan_data <- list(N=nrow(VoteData), T=max(VoteData$YearIndex), 
                   K=max(VoteData$VoteIndex), J=max(VoteData$SenIndex),
                   y=VoteData$Vote, t=VoteData$YearIndex,
                   k=VoteData$VoteIndex, j=VoteData$SenIndex)



dynamic_model <- "
data {
  int<lower=1> J;         //Senators
  int<lower=1> K;         //Proposals
  int<lower=1> N;         //no. of observations
  int<lower=0> T;         // number of different time periods
  int<lower=0> y[N];      // response for n; y = 0, 1
  int<lower=0> j[N];      //Senator for observation n
  int<lower=0> k[N];      //Proposal for observation n
  int<lower=0> t[N];     // time period for obs n
}

parameters {
  vector[K] alpha;
  vector[K] beta;
  vector[J] theta[T];
}
model {
  theta[1] ~ normal(0, 1);
  for (i in 2:T){
  theta[i] ~ normal(theta[i - 1], 1);
  }
  alpha ~ normal(0, 1);
  beta ~ normal(0, 5);
  for (n in 1:N)
  y[n] ~ bernoulli_logit(theta[t[n], j[n]] * beta[k[n]] - alpha[k[n]]);
}"


dyn_fit <- stan(model_code = dynamic_model, data=stan_data, iter=5000, 
                  warmup=2500, thin=5, chains=4, seed=1234, cores=4)

