data {
  int<lower=1> J;                 //Legislators
  int<lower=1> K;                 //Proposals
  int<lower=1> N;                 //no. of observations
  int<lower=1, upper=J> j[N];     //Legislator for observation n
  int<lower=1, upper=K> k[N];     //Proposal for observation n
  int<lower=0, upper=1> y[N];     //Vote of observation n
  int<lower=1> D;                 //No. of dimensions (here 2)
}
parameters {
  real alpha[K];                    //difficulty (intercept)
  matrix[K,D] beta;                 //discrimination (slope)
  matrix[J,D] theta;                //latent trait (ideal points)
}
model {
  alpha ~ normal(0,10); 
  to_vector(beta) ~ normal(0,10); 
  to_vector(theta) ~ normal(0,1); 
  theta[1,1] ~  normal(1, .01);     //constraints, ideal points, dimension 1
  theta[2,1] ~ normal(-1, .01);  
  beta[1,2] ~ normal(-4, 2);        // beta constraints
  beta[2,2] ~ normal(4, 2); 
  beta[1,1] ~ normal(0, .1); 
  beta[2,1] ~ normal(0, .1); 
for (n in 1:N)
 y[n] ~ bernoulli_logit(theta[j[n],1] * beta[k[n],1] + theta[j[n],2] * beta[k[n],2] - alpha[k[n]]);
}