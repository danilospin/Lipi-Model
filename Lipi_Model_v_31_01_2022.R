#################### Model analysis of Porcile et al. 2021 ##########################

# Please see this as an exercise, the parameter values are a theoretical representation of
# reasonable values, and are not part of a calibration process

library(deSolve)
library(rootSolve)
library(psych)
library(scatterplot3d)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

### Which case? 
### 1: developmentalist state. 2: Conflicting claims (we do not add this figure). 3: financialization
case=1

#List of Parameters of the Model:

# The parameter values is a stylized representation, that can be used for 
# Sensitive analysis and for understanding the behaviour of the different models

alpha=1 #Kaldor-Verdoorn parameter
beta=0.2 #Institutional Inertia
gamma=2 #growth elasticity to RER
#mux=0.06 #mum=0.02  #gamma=1-mux+mum
pi=3 # Income elasticity of demand for imports
u=vartheta=1 #Speed of adjustment of the RER
v=1 #Speed of adjustment of the quadratic RER
qd=qt=3 #Desired RER for developmentalist state
yf=0.02 #Foreign growth rate
tau=0.2 #Share of domestic goods

#Initial values  
epsilon0=3 #Initial income elasticity of exports
q0=2 #Initial RER

# Parameters for conflicting claims  
qg=2.1 #Desired government RER
qw=1.3 #Desired workers RER
h=0.3
j=0.4




####################################################################
#################### MAIN STRUCTURE OF THE MODEL ###################
####################################################################

#y=(epsilon/pi)*yf+(gamma/pi)*qdot
#epsilondot=(alpha/(1+beta))*(gamma/pi)*qdot

#P=z*a*W
#Phat=zhat+ahat+what
#q=ln*(Pf*E/P)
#qdot=Ehat+(zfhat-zhat)+(afhat-ahat)+(wfhat-what)
#y=(e/pi)*yf+(gamma/pi)*(Ehat+(zfhat-zhat)+(afhat-ahat)+(wfhat-what))
#epsilondot=(alpha/(1+beta))*(gamma/pi)*(Ehat+(zfhat-zhat)+(afhat-ahat)+(wfhat-what))

#a=L/Y
#sigma=(z-1)/z
#######################################################################
#######################################################################

######################## CASES CLOSURE ################################

#CASE 1

if (case==1)  
{
  
  ################ Developmentalist State #####################
  
  ############### CHARACTERISTICS  OF MODEL ################### 
  # zfhat=zhat
  # what=-ahat
  # wfhat=-afhat
  #     Then
  # qdot=Ehat
  # Ehat=vartheta*(qd-q)
  
  #y=(e/pi)*yf+(gamma/pi)*vartheta*(qd-q)
  #epsilondot=(alpha/(1+beta))*(gamma/pi)*vartheta*(qd-q)
  ############################################################
  
  developm <- function (t, y, parms) {
    with(as.list(y), {
      #Differential Equations
      dq=vartheta*(qt-q)
      list(c(dq)) })
  }
  #Initial Conditions
  yini <- c(q=q0)
  #Computing the dynamic equation (ODE)
  times <- seq(from = 0, to = 99, by = 0.1)
  out <- ode(y = yini, times = times, func = developm,
             parms = NULL)
  #Correctly graph the equations
  q=out[,2]
  
  #Integrating epsilon in relationship to q
  epsilond=epsilon0+(alpha/(1+beta))*(gamma/pi)*vartheta*((q-q0)^2)/2

  #dynamic behavior for the graphs
  yfvar=(0:10)/100
  y0=(epsilon0/pi)*yfvar
  y1=(1/pi)*((epsilon0)*yfvar)+((gamma/pi)*vartheta*(qd-q0))/20
  yd=(yfvar/pi)*(epsilon0+(alpha/(1+beta))*(gamma/pi)*vartheta*((qd-q0)^2))
  depsilond=epsilond[-1]
  #Graphs
  par(mfrow=c(1,2), mar=c(3.1, 2.9, 2.5, 1), mgp=c(2, 1, 0), las=0, cex.lab=0.7, cex.axis=0.7, cex.main=0.7, cex.sub=0.7)

  pdf(file="case1.pdf")
  #FIGURE 1
    par(mfrow=c(1,1))
    plot(y0,type="l",col="black", ylim=c(0,0.15), xlab="y*", ylab="y")
    lines(yd,type="l", col="red")
    lines(y1,type="l", col="blue")
    abline(v = 6, col = "darkgreen")
    
    #FIGURE 2a
    plot(q[1:100], lwd = 2, type='l', main="", xlab="time", ylab="q")
    
    #FIGURE 2B
    plot(q[1:999], depsilond[1:999], lwd = 2, type='l', main="", xlab="q", ylab="epsilon dot", xlim=c(2.5,3))
    abline(v=2.7)
    dev.off()
  
} 

if (case==1.2)  #Graphs with same shape, but different sensitivities
{
  ###############################################################################
  ###########Case with a quadractic equation#####################################
  #New dynamic equation
  #Ehat=vartheta*(u*(qd-q)-v*(qd-q)^2)
  
  #qt-d0<3u/2v for a positive impact on income elasticity of exports
  # graphs are similar to the first case, but if the effect is contrary, the model then explodes
  
  u=0.6
  v=0.4
  
  developm2 <- function (t, y, parms) {
    with(as.list(y), {
      #Differential Equations
      dq=vartheta*(u*(qd-q)-v*(qd-q)^2)
      list(c(dq)) })
  }
  #Initial Conditions
  yini <- c(q=q0)
  #Computing the dynamic equation (ODE)
  times <- seq(from = 0, to = 999, by = 0.1)
  out <- ode(y = yini, times = times, func = developm2,
             parms = NULL)
  #Correctly graph the equations
  q=out[,2]
  
  epsilond=epsilon0+(alpha/(1+beta))*(gamma/pi)*vartheta*((u*(q-q0)^2)/2-v*((q-q0)^3)/3)
  depsilon= epsilond-epsilon0
  
  # Growth changes
  y0=(epsilon0/pi)*yfvar
  y1=(1/pi)*((epsilon0)*yfvar)+(gamma/pi)*vartheta*(u*(qd-q0)-v*(qd-q0)^2)
  yd=(yfvar/pi)*(epsilon0+(alpha/(1+beta))*(gamma/pi)*vartheta*((u*(qd-q0)^2)/2-v*((qd-q0)^3)/3))
  plot(y0,type="l",col="red")
  lines(yd,type="l", col="green")
  
  yd=yd*1.2-0.003 #Adjustment to fit the graph
  y1=y1-0.13
  pdf(file="case1.2.pdf")
  #FIGURE 1
  par(mfrow=c(1,1))
  plot(y0,type="l",col="black", xlim=c(2,4), ylim=c(0.01,0.03), xlab="y*", ylab="y")
  lines(yd,type="l", col="red")
  lines(y1,type="l", col="blue")
  abline(v = 6, col = "darkgreen")
  
  #FIGURE 2a
  plot(q[1:100], lwd = 2, type='l', main="", xlab="time", ylab="q")
  
  #FIGURE 2B
  plot(q[1:999], depsilond[1:999], lwd = 2, type='l', main="", xlab="q", ylab="epsilon dot", xlim=c(2.5,3))
  abline(v=2.7)
  dev.off()
  }


#Case 2

################# CONFLICTING CLAIMS ########################

############### CHARACTERISTICS  OF MODEL ################### 
#P=(P^tau)*(Pf*E)^(1-tau)
#omega=1/z*a
#what=varsigma*(Ln(1/(z*(e^(qw*(1-tau)))))-Ln(1/(z*(e^(q*(1-tau))))))
#what=h*(q-qw) #h=varsigma*(1-tau)
#Ehat=j*(qg-q)
#qdot=j*(qg-q)-h*(q-qw)
#being h=j-1
#qdot=j*(qg-q)-(j-1)*(q-qw)


if (case==2)
{  
  
  conflic <- function (t, y, parms) {
    with(as.list(y), {
      #Differential Equations
      dq=j*(qg-q)-(j-1)*(q-qw)
      list(c(dq)) })
  }
  #Initial Conditions
  yini <- c(q=q0)
  #Computing the dynamic equation (ODE)
  times <- seq(from = 0, to = 99, by = 0.1)
  out <- ode(y = yini, times = times, func = conflic,
             parms = NULL)
  #Correctly graph the equations
  q=out[,2]
  
  #Conflicting Claims and the RER
  y=(epsilon0/pi)*yf+(gamma/pi)*(j*(qg-q)-(j-1)*(q-qw))
  epsilondot=(alpha/(1+beta))*(gamma/pi)*(j*(qg-q)-(j-1)*(q-qw))
  epsilone=epsilon0+(alpha/(1+beta))*(gamma/pi)*(-(qw+qg)*((1/2)*(((qw*(1-j)+qg*j)^2)-q0^2))+(qw*(1-j)+qg*j-q0)*(qw*(1-j)+qg*j)) #test
  plot(log(y), lwd = 2, type='l', main="", xlab="time", ylab="y")
  plot(epsilondot, lwd = 2, type='l', main="", xlab="time", ylab="epsilondot")
  plot(q, lwd = 2, type='l', main="", xlab="time", ylab="q")
  plot(q, epsilondot, lwd = 2, type='l', main="", xlab="q", ylab="epsilon dot")
  
  
 #Start Sensitivity Analysis in j  
 y2=matrix(0, 10, length(q))
 for(j in 1:10)
 {y2[j,]=(epsilon0/pi)*yf+(gamma/pi)*((j/10)*(qg-q)-(1-(j/10))*(q-qw))}
 
 #FIGURE
 #Effects of changes of j in growth - we see that growth declines 
 #the weaker the effects of the persistent path dependence
 
 orderedcolors <- rainbow(5)
 plot(y2[1,1:100], type="l", ylim=c(-4.5,0.2), ylab="y", xlab="time", )
 for(i in 2:5)
 {lines(y2[i,1:100], type="l", col=orderedcolors[i]) }
 legend(x = "topright",          # Position
        legend = c("j=0.1", "j=0.2", "j=0.3", "j=0.4", "j=0.5"),  # Legend texts
        lty = c(1, 1,1,1,1),           # Line types
        col = c("black", orderedcolors[2],orderedcolors[3],orderedcolors[4],orderedcolors[5]),           # Line colors
        lwd = 2)                 # Line width
 
 
 # Saving the plots in file
 pdf(file="case2.pdf")
 plot(y2[1,1:100], type="l", ylim=c(-4.5,-0.15), ylab="y", xlab="time", )
 for(i in 2:5)
 {lines(y2[i,1:100], type="l", col=orderedcolors[i]) }
 legend(x = "topright",          # Position
        legend = c("j=0.1", "j=0.2", "j=0.3", "j=0.4", "j=0.5"),  # Legend texts
        lty = c(1, 1,1,1,1),           # Line types
        col = c("black", orderedcolors[2],orderedcolors[3],orderedcolors[4],orderedcolors[5]),           # Line colors
        lwd = 2)                 # Line width
 dev.off()
 
#epsilone=epsilon0+(alpha/(1+beta))*(gamma/pi)*((qe^2)/2+(j-1)*qw*qe-j*qg*qe-(q0^2)/2-(j-1)*qw*q0+j*qg*q0) #My version - test
  #test with j=1 and qg=qd
}   

############## Financialization and neoliberal coalition #######################
if (case==3)
{
  #rdot=rho0*(what-theta)-rho1*r
  #rdot=rho0*(h*(q-qw)-theta)-rho1*r
    #rdot=-g+rho*q-rho1*r
  #qdot=phi*(rf-r)
  
  rho0=0.02 #adjustment speed to inflation target
  h=0.8 # adjustment speed between real exchange rate
  rho=rho0*h
  rho1=0.2 # Sensitivity of real interest rate changes to itself
  rf=0.02  # International real interest rate
  r0=0.05
  phi=0.01 # Adjustment parameter
  theta=0.1 # Inflation target
  theta2=0.01 # Inflation target (final)
  
  financ <- function (t, y, parms) {
    with(as.list(y), {
      #Differential Equations
      dq=phi*(rf-r)
      dr=rho0*(h*(q-qw)-theta)-rho1*r
      list(c(dq, dr)) })
  }
  #Initial Conditions
  yini <- c(q=q0, r=r0)
  #Computing the dynamic equation (ODE)
  times <- seq(from = 0, to = 999, by = 1)
  out <- ode(y = yini, times = times, func = financ,
             parms = NULL)
  #Correctly graph the equations
  q1=out[,2]    
  r1=out[,3]
  q=out[,2]    
  r=out[,3]
  re=rf
  rfe=rf*2 #Adjust to fit the graph
  theta2=5
  qe=rho0*h*qw+rho0*theta+rho1*r/(rho0*theta)
  qe2=rho0*h*qw+rho0*theta2+rho1*r/(rho0*theta2)
  
#Figure 4
  plot(qe,r,type="l", col="red", ylim=c(0.03,0.05), xlim=c(2,5))
  abline(h=rfe, col="blue")
  lines(qe2*15,r,type="l", col="black")
  
  pdf(file="case3.1.pdf")
  plot(qe,r,type="l", col="red", ylim=c(0.03,0.05), xlim=c(2,5))
  abline(h=rfe, col="blue")
  lines(qe2*15,r,type="l", col="black")
  dev.off()
  
#################### Cycle ##############################
  
  beta1=0.1
  beta2=0.2
  
  financ1 <- function (t, y, parms) {
    with(as.list(y), {
      #Differential Equations
      dq=phi*(rf-r)
      dr=rho0*(h*(q-qw)-theta)-rho1*0*r
      list(c(dq, dr)) })
  }
  #Initial Conditions
  yini <- c(q=q0, r=r0)
  #Computing the dynamic equation (ODE)
  times <- seq(from = 0, to = 999, by = 1)
  out <- ode(y = yini, times = times, func = financ1,
             parms = NULL)
  q2=out[,2]    
  r2=out[,3]
  plot(q2,type="l",col="red")
  plot(r2,type="l", col="green")
  qdot=q2-c(q2[-1],2)
  #PATH DEPENDENCY
  #Case path dependence
  edot1=(alpha/(1+beta1)*(gamma)/pi)*q2 #if qdot>0
  edot2=(alpha/(1+beta2)*(gamma)/pi)*q2 #if qdot<0
  
    #figure 5b
  edotFinal=edot1
  for(i in 1:1000)
  {edot2=i/1000
  edotFinal[i]=edot1[i]-edot2}
  
    plot(edotFinal, type="l")
    time=1:1000
    fit <- glm(edotFinal~time)
    abline(fit, col="red", lwd=1)

    #figure 5a
    plot(qdot, edotFinal, type="l")
    
    pdf(file="case3.2.pdf")
    plot(qdot, edotFinal, type="l")
    plot(edotFinal, type="l")
    abline(fit, col="red", lwd=1)
    dev.off()
    
}