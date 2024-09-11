
using SNNUtils
using Plots

triplet = SNNUtils.pfister_visualcortex()
o1stdp = 0.0
o2stdp = 0.0
r1stdp = 0.0
r2stdp = 0.0

pre_rate = 20
post_rate = 30
simtime = 1000
dt = 0.1f0
pre_spikes = SNNUtils.PoissonInput(pre_rate, simtime, dt)[1, :]
post_spikes = SNNUtils.PoissonInput(post_rate, simtime, dt)[1, :]

for tt = 1:round(Int, simtime / dt)
    # ## Duplet traces update before learning rule
    pre_spiked = pre_spikes[tt]
    post_spiked = post_spikes[tt]

    post_spiked && (o1stdp += 1.0)
    pre_spiked && (pre_spiked += 1.0)

    if exc_prespikes[syn]
        W -= o1stdp * (triplet.A⁻₂ + triplet.A⁻₃ * r2stdp[syn])
    end

    if post_spiked
        W += r1stdp[syn] * (triplet.A⁺₂ + triplet.A⁺₃ * o2stdp)
    end

    post_spiked && (o2stdp += 1.0)
    pre_spiked && (r2stdp += 1.0)

    r2stdp .*= exp(-dt / triplet.τˣ)
    o2stdp *= exp(-dt / triplet.τʸ)
    r1stdp .*= exp(-dt / triplet.τ⁺)
    o1stdp *= exp(-dt / triplet.τ⁻)
end
# AMPAsynapses[findall(AMPAsynapses .> max_efficacy)] .= max_efficacy
# AMPAsynapses[findall(AMPAsynapses .< 0.)] .=0
