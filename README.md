# Bayesian Ideal Point IRT Models
Some IRT ideal point models that may be useful for some folks. They are coded to be run with Stan. `JAGS` has often been used to run these types of models but it can take a very long time. The reason for this is that `JAGS` is unable to build a Directed Acyclic Graph from the unobserved regressor in:

![](http://i.imgur.com/gGoK7mr.png?1)
  
(see [here](https://sourceforge.net/p/mcmc-jags/discussion/610037/thread/5c9e9026/ ))

(*y_{ij} = \beta_j x_i - alpha_j*  if the image doesn't render)


