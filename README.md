# Bayesian Ideal Point IRT Models in R using JAGS and Stan

*Ideal point* IRT models differ from regular IRT in that the discrimination parameter in a 2-parameter IRT model cannot be negative, whereas in an ideal point model it can. This is to capture the fact that variation along the latent trait can move in both directions in the political context (for example, along a left-right scale). In regular IRT, this does not make much sense as movement upwards along the scale of the latent trait (usually some type of ability) should be associated with positive movement in levels of the actual unobserved trait.

`BUGS` or `JAGS` users can find a host of regular IRT models in Ian Curtis' [paper](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwjEk-b0_oLOAhUGDpAKHd4CCjMQFggeMAA&url=https%3A%2F%2Fwww.jstatsoft.org%2Farticle%2Fview%2Fv036c01%2Fv36c01.pdf&usg=AFQjCNEs9TOxtdwHK3wdInSin01WCa-Iyw&sig2=Pg9jjBeFewZIzYaAIE_gTg). Here I have included a bunch of *ideal point* IRT models, coded in Stan and JAGS for use in R. `JAGS` is commonly used in the field for this type of model, but I would recommend using Stan, as `JAGS` can take a very long time. The reason for this is that `JAGS` is unable to build a Directed Acyclic Graph from the unobserved regressor in the basic ideal point IRT equation:

![](http://i.imgur.com/gGoK7mr.png?2)
  
(see [here](https://sourceforge.net/p/mcmc-jags/discussion/610037/thread/5c9e9026/ )).

Among the models saved here are the basic IRT ideal point model, a multidimensional version, a dynamic version, and a multilevel version. Grouplet and testlet models are also included. The basic IRT ideal point model is due to [Jackman](http://pan.oxfordjournals.org.sci-hub.cc/content/9/3/227.abstract). There are various ways to prepare the data for Stan. For beginners, the method used in '2Dmodel.R' is easy and intuitive: the data matrix can be inspected for the choice of constraints and so on. For those familiar with Stan, the data is prepared in a quicker way in the other files. ('2Dmodel.R' and 'MultidimensionaIRT_Stan.R' are basically identical, but the latter uses the tidier method of data preparation.)


