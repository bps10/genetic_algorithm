# Genetic optimize

This repository contains some functions for fitting a reduced spiking neuron model to training data. The algorithm included here is very simple implementation of an evolutionary or [genetic algorithm][gen] algorithm. It is a straight forward search heuristic based on the simplest principles of evolution: fitter individuals out compete others and successfully breed with some rate of random mutation in the process. Breeding allows two successful individuals to share traits, while random mutation events introduce new 'phenotypes' into the population. Therefore, the number of individuals in each generation as well as the mutation rate will have substantial impacts upon the behavior of the algorithm.

## Getting started

You should find the script called `optimize_script.m` which demonstrates how to use the genetic algorithm. This script will load some training data, which is merely a small section of a voltage trace from a white noise whole cell current clamp experiment. The current file is the current that was injected into the neuron and gave rise to the voltage trace. The goal here is to find parameters of a simple spiking model that gives rise to a similar voltage trace in response to the same current that the biological neuron experienced. We can then test the model on larger stretches of data that the model was not trained with to see how well it performs more generally (that data is not included in this repository).

## Setting parameters

The predominant tweaking in the fitting regiment was related to the sampling range and frequency of the free parameters and the error function.  The latter was largely trial and error.  Of course, increasing the sampling range and frequency provides a greater chance of finding a fit, but it also increases the parameter space making a fit more difficult to find.  The error function (or fitness function) was a little more interesting. 

## Fitness function

Developing a good fitness function is one of the most important aspects of creating a successful genetic algorithm. The idea is exactly analogous to evolution, we want the best parameters to survive and mate, while discarding the others. However, defining what exactly a good fitness measure constitutes in the context of electrophysiology is not entirely straightforward. 

One approach to this problem is to take the root mean squared (RMS) difference between the model and training voltage traces. In the case of the model here this approach will quickly (just a handful of generations) converge upon a good fit to the subthreshold oscillations, but virtually never produced a model that spikes.  This makes sense since spiking at any time other than precisely when the data spikes would increase the RMS error. Another approach then is to use the derivative of the traces. The idea being that the rate of change is highest when the voltage is spiking and therefore should encourage parameters that produce spiking. However, does not seem to be the case in this example, likely for a similar reason: spiking any time other than exactly coincident to the training data punishes the model. A different approach is to add a ‘reward’ for a coincident spike (+- 3ms from the time of spike - this is the `training_data.delta` parameter in `optimize_script.m`) and a ‘punishment’ for extra spiking. In this way we can encourage the model to spike close to the time of the spikes in the actual data while discouraging excessive spiking - without punishment the algorithm could optimize itself by spiking all the time. Finally, we can combine these three measures with some weights on how important the punishment and reward should be:

    Error = RMS + dVdt_error + k * punish - j * reward 

In the current case a k of 2-3 and a j of 5-7 seem to be ideal under the algorithm conditions that I have explored. Using this error function, the algorithm was able to find a solution that fit the training data pretty quickly and included spiking at the appropriate times, usually capturing 4-5 spikes of the 5 contained in the training set with few to no additional spikes.

## Model

The model implemented here is a two variable quadratic integrate and fire model developed by Izhikevich. A more detailed account can be found in Izhikevich's ([book][izh]). As it is currently implemented, the model required 9 different parameters.

### Files

* optimize_script.m:

* genetic_optimize.m: 

* QUADmodel.m: 

* gen_params.m:

* find_spikes.m: This is a dead simple spike finding algorithm based on zero crossing events. This is fine for the current project but more complicated procedures are available and often necessary especially when not in whole cell mode. One popular technique uses [wavelets][wave] to accentuate spikes in the data.

[wave]: http://en.wikipedia.org/wiki/Wavelet
[gen]: http://en.wikipedia.org/wiki/Genetic_algorithm
[izh]: http://www.izhikevich.org/publications/dsn.pdf