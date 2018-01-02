library(rstan) # loads ggplot2 by default
library(dplyr)
library(plyr)

load("data/votes.Rda")
load("data/votes_data.Rda")
load("saved_runs/1d_model_stan.Rda")

votes_data <- votes_data %>% 
  select(legislator_id, legislator_party, government) %>% 
  distinct(legislator_id, .keep_all = TRUE)

ips <- summary(stan.fit, pars = "theta", probs = c(0.025, 0.975))
ips <- as_data_frame(ips$summary) %>% 
  mutate(legislator_id = row.names(m_votes),
         index = gsub("[A-Za-z_]*", "", legislator_id),
         index = as.numeric(index)) %>% 
  left_join(votes_data) %>% 
  rename(lower = `2.5%`, upper = `97.5%`) %>% 
  arrange(index)

y <- 1:nrow(ips)
ggplot(ips, aes(x = mean, y = y, colour = government)) +
  geom_point() +
  geom_errorbarh(aes(xmin = lower, xmax = upper)) + 
  theme_minimal() + xlab("Ideal Point") +
  theme(axis.title.y = element_blank(), 
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position = "bottom") +
  scale_x_continuous(breaks = c(-1, 0, 1), limits = c(-1.25, 1.25)) +
  scale_colour_manual(values = c("#2F3061", "#D62839"))

## for a 2-dimensional plot, we use a hull to highlight things.
# Assuming you ran the code in 2Dmodel_Stan.R, 
# 1-50 is dimension 1, 51-100 dimension 2:
ips <- summary(stan.fit, pars = "theta", probs = c(0.025, 0.975))
ips <- as_data_frame(ips$summary)
ips_d1 <- ips[1:50, ]
ips_d1 <- rename(ips_d1, meanD1 = mean)
ips_d2 <- ips[51:100, "mean"]
ips_d2 <- rename(ips_d2, meanD2 = mean)
ips <- bind_cols(ips_d1, ips_d2)
ips <- ips %>% 
  mutate(legislator_id = row.names(m_votes),
         index = gsub("[A-Za-z_]*", "", legislator_id),
         index = as.numeric(index)) %>% 
  left_join(votes_data) %>% 
  arrange(index)

find_hull <- function(x) x[chull(x$meanD1, x$meanD2), ]
hulls <- ddply(ips, "government", find_hull)

ggplot(ips, aes(x = meanD1, y = meanD2, colour = government, 
                fill = government)) + 
  geom_point(shape = 19, size = 2.5) + 
  geom_polygon(data = hulls, alpha = .18) + 
  scale_colour_manual(values = c("#2F3061", "#D62839")) + 
  scale_fill_manual(values = c("#2F3061", "#D62839")) + 
  theme_minimal() + 
  theme(axis.title=element_blank(), legend.position="none") + 
  geom_hline(yintercept = 0, size = .3) + geom_vline(xintercept = 0, size = .35) +
  scale_x_continuous(limits = c(-1.5, 1.25)) #if necessary to adjust scale
