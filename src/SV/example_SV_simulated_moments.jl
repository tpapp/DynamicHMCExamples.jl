using StatsPlots
include("SV.jl")
# Extract the parameters and plot the posteriors
σu_hat = [i[1][1] for i in posterior]
sigu = density(σu_hat)
ρhat = [i[2][1] for i in posterior]
rho = density(ρhat)
σe_hat = [i[3][1] for i in posterior]
sige = density(σe_hat)
p = plot(sige, rho, sigu, layout=(3,1),legend=false)
@show display(p)
