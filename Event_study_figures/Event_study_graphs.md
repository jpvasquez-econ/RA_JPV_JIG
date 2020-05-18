### Task: event study graphs using python and latex

**Purpose**: To produce a latex  figure of event-study coefficients using the `tiks` latex package.

#### What is an event study regression?

An event study regression is a regression like the following:
$$
y_{it}=  X^\top_{it} \beta +   \sum_{k=\underline{C}}^{\overline{C}} \theta_k   D^k_{it} + \varepsilon_{it},
$$
where $y_{it}$ is an outcome of interest. The subscript $i$ refers to the unit of study (for example, a person or a firm) and $t$ refers to the calendar time (e.g., months or years).  $X^\top_{it}$ is a vector of explanatory variables. 

We define the event-time dummies as $D^k_{it} : = \mathcal{1}[t = \tau_i + k]$ $\forall k \in [\underline{C},\overline{C}]$,  where $\mathcal{1}[.]$ is the indicator function and $\tau_i$ is the year when an "event" happens to unit $i$ . $\varepsilon_{it}$ is an error term.  The coefficients $\theta_k$ are what we call the "event study coefficients". To avoid multicollinearity, one needs to normalize one of them to zero. Usually one takes  $\theta_{\textit{-1}}=0$. 

We want a plot with the value of $\theta_k$ on the Y-axis and $k$ on the X-axis. The plot should also have the confidence interval for each coefficient. 

You could see similar plots on page 36 of one of my papers in this [link](https://manelici-vasquez.github.io/coauthored/Effects_of_Joining_MNC_Supply_Chains_body.pdf). Right now, those plots are produced in Stata and imported to latex as a pdf.  The idea is to produce nicer-looking versions of these plots

#### What is `tiks`?

It is a latex package that one can use to produce figures in latex. One provides the coordinates and the type of graph and latex compiles a nice figure. See several examples of how it works in this [link](http://pgfplots.sourceforge.net/gallery.html). 

#### Inputs for the task

The input file is a CSV file with three columns: 

1. The event-time $k \in [\underline{C},\overline{C}]$
2. The $\overline{C}-\underline{C}+1$ estimated coefficients $\hat\theta_k$ from the regression (one coefficient for each $k$. 
3.  The standard errors associated to each coefficient

#### Output of the task

The objective of this task is that you create a python program such that no matter the values of $\underline{C}$ , $\overline{C}$, $\theta_k$, etc, the program produces the necessary .tex file that can be inputted to latex in order to produce an event study figure.

  