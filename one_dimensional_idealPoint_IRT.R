
# load data:
load("data/votes.Rda")


irt_1d <- function(type = c("JAGS", "Stan"), model = c("1D", "2D"),
                   n_chains = 2, n_adapt = 1000, n_update = 5000,
                   n_iter = 1000, summarise = TRUE){
  
  language = match.arg(type, choices = c("JAGS", "Stan"))
  mod = match.arg(model, choices = c("1D", "2D"))
  
  if(language == "JAGS"){
    library(rjags)
    
    if(mod == "1D"){
      
      j_data = list(y = votes, N = nrow(votes), M = ncol(votes))
      
      j_model = jags.model(file = "models/JAGS_1D_IRT.txt", data = j_data,
                           n.chains = n_chains, n.adapt = n_adapt)
      update(j_model, n.iter = n_update)
      samples = coda.samples(j_model, variable.names = c("theta", "beta", "alpha"), n.iter = n_iter)
      summaries <- summary(samples)
      jags_output = list(summaries, j_model, samples)
      stats <- as.data.frame(summ$statistics)
      stats$params <- rownames(stats)
      
      return(jags_output)
    }
    
  } else{
    library(rstan)
  }
  
}



