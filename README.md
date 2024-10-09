## Update 10/2024: This repository is no longer being maintained. An actively-maintained, updated version of the GSPulse algorithm is now available open-source [here](https://github.com/jwai-cfs/GSPulse_public). 


## The very quickstart guide

**Description:** GSPD lets you design a sequence of Grad-Shafranov plasma equilibria for a plasma pulse. Equilibria satisfy both force balance and circuit dynamics. 

```
Step 1: run startup.m
Step 2: cd to a <tokamak>/pulses/EXAMPLE folder and run pulse.m
```

The algorithm is described in detail in an arxiv [preprint](https://arxiv.org/abs/2306.13163), with peer-reviewed journal publication forthcoming. Please cite as appropriate if you use the code for any published work. 


## The longer quickstart guide 

**Description:** GSPD is a free-boundary equilibrium solver that solves multiple equilibria at the same time while also satisfying the circuit dynamics of the tokamak. The optimization can be specified so that power supply current and voltage limits are observed. 

It is designed to answer questions like:

- How fast can the power supplies deliver requested shape changes?
- How long can the shape target be maintained while supplying flux for the Ip evolution? 
- Identify the coil and vessel current evolution during rampup, when shape is changing and vessel currents also play a large role. 


Note that the equilibria are computed all in feedforward, this is is not a feedback flight simulator. 


The easiest way to get started is to copy and modify the examples. These are located in the \<tokamak\>/EXAMPLE folders. For each pulse of equilibria, the user must specify an initial condition, target shapes, power supply requirements, and target evolution of plasma scalars like plasma current and resistance. This is done in the `pulse.m` script and looks like this:

```
shapes           = define_shapes()
plasma_scalars   = define_plasma_scalars();
init             = define_init();
settings         = define_optimization_settings();
targs            = define_optimization_targets();
weights          = define_optimization_weights();

soln = GSPD(tok, shapes, plasma_scalars, init, settings, targs, weights);

```

Examples are included for the NSTX-U tokamak. A description of the included examples is as follows:


- **nstxu EXAMPLE_001:** equilibria sequence for an entire nstxu shot through rampup and transition from limited to diverted. Medium elongation. Illustrates features such as that for the same shape, strike points move during the Ohmic coil ramp.

- **nstxu EXAMPLE_002:** Similar to above, but for a high elongation shot (loosely replicates 204118) that is closer to current limits. 


To run any of these:
```
Step 1: run startup.m
Step 2: cd to nstxu/pulses/EXAMPLE folder and run pulse.m
```






