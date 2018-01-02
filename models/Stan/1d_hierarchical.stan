data {
  int<lower=1> J; //Legislators
  int<lower=1> K; //Proposals/bills
  int<lower=1> N; //no. of observations
  int<lower=1, upper=J> j[N]; //Legislator for observation n
  int<lower=1, upper=K> k[N]; //proposal for observation n
  int<lower=0, upper=1> y[N]; //vote of observation n
}
parameters {
  vector[K] alpha;
  vector[K] beta;
  vector[J] theta;
  vector[J] mu_theta;
}
model {
  alpha ~ normal(0,10); 
  beta ~ normal(0,10); 
  theta ~ normal(mu_theta,1);
  mu_theta ~ normal(0, 10); 
  theta[1] ~  normal(1, .01);  //constraints
  theta[2] ~ normal(-1, .01);  
  for (n in 1:N)
  y[n] ~ bernoulli_logit(theta[j[n]] * beta[k[n]] - alpha[k[n]]);
}