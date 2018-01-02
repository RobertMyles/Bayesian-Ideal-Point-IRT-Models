data {
  int<lower=1> J;         //legislators
  int<lower=1> K;         //Proposals
  int<lower=1> N;         //no. of observations
  int<lower=0> T;         // number of different time periods
  int<lower=0> y[N];      // response for n; y = 0, 1
  int<lower=0> j[N];      //Legislator for observation n
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
}