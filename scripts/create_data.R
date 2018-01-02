# create vote matrix of votes. Row names are voters, column names are 
# votes ('bills' or 'rollcalls'). 50 legislators, 150 votes.

library(dplyr)

# simulate data: 100 legislators, 150 votes
N <- 50
M <- 150
m_votes <- matrix(NA, nrow = N, ncol = M)
# Liberals (majority Gov. party)
for(n in 1:20){
  m_votes[n, ] <- rbinom(M, size = 1, prob = 0.9)
}
# Conservatives (uneasy coalition)
for(n in 21:32){
  m_votes[n, ] <- rbinom(M, size = 1, prob = 0.7)
}
# Socialists (opposition)
for(n in 33:40){
  m_votes[n, ] <- rbinom(M, size = 1, prob = 0.3)
}
# Greens (opposition)
for(n in 41:45){
  m_votes[n, ] <- rbinom(M, size = 1, prob = 0.25)
}
# Religious (opposition)
for(n in 46:48){
  m_votes[n, ] <- rbinom(M, size = 1, prob = 0.1)
}
# Independents (random)
for(n in 49:50){
  m_votes[n, ] <- rbinom(M, size = 1, prob = 0.5)
}
rm(n)

votes_data <- data_frame(
  vote_id = rep(paste0("Vote_", 1:M), each = N),
  legislator_id = rep(1:N, times = M),
  vote = as.vector(m_votes),
  legislator_party = ""
) %>% 
  mutate(legislator_party = case_when(
    legislator_id <= 20 ~ "The Classic Liberal Party",
    legislator_id > 20 & legislator_id <= 32 ~ "The Conservative Party",
    legislator_id > 32 & legislator_id <= 40 ~ "The Socialist Party",
    legislator_id > 40 & legislator_id <= 45 ~ "The Green Party",
    legislator_id > 45 & legislator_id <= 48 ~ "The Religious Party",
    TRUE ~ "Independent"),
    legislator_id = paste0("Legislator_", legislator_id),
    government = ifelse(legislator_party %in% c("The Classic Liberal Party",
                                                "The Conservative Party"), 
                        "Government", "Opposition"),
    index = gsub("[A-Za-z_]*", "", vote_id),
    index = as.numeric(index),
    year = ifelse(index <= 75, "2017", "2018")) %>% 
  select(-index)

dimnames(m_votes)[[1]] <- unique(votes_data$legislator_id)
dimnames(m_votes)[[2]] <- unique(votes_data$vote_id)

# make the first two voters roughly opposite:
# put voter from religious party in 2nd row
religious <- m_votes[46, ]
liberal <- m_votes[2, ]
m_votes[2, ] <- religious
m_votes[46, ] <- liberal
dimnames(m_votes)[[1]][2] <- "Legislator_46"
dimnames(m_votes)[[1]][46] <- "Legislator_2"

# and make a random subset NA (missed votes, common in real datasets):
m_votes[sample(seq(m_votes), 50)] <- NA
# save:
save(votes_data, file = "data/votes_data.Rda")
save(m_votes, file = "data/votes.Rda")
