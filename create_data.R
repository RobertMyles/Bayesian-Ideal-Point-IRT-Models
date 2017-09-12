# create vote matrix of votes. Row names are voters, column names are votes ('bills' or 'rollcalls')

library(dplyr) # for pipe, cos I like it
# create voters:
voters <- seq(from = 1, to = 150, by = 1) %>% paste0("Voter ", .)
# create bills:
bills <- seq(from = 1, to = 200, by = 1) %>% paste0("Bill ", .)
# create matrix of votes:
votes <- matrix(rbinom(150*200, 1, prob = 0.75), ncol = 200, nrow = 150)
# put names on the matrix:
dimnames(votes)[1] <- list(voters)
dimnames(votes)[2] <- list(bills)
# make the first two voters roughly opposite:
votes[1, ] <- ifelse(votes[2, ] == 0, 1, 0)
# but let's make them agree on a small subset of votes:
votes[1:2, c(3, 15, 35, 55, 61, 90, 120, 166, 182, 191, 199)] <- 1
# save:
save(votes, file = "data/votes.Rda")
