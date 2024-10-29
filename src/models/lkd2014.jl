
"""
Litwin-Kumar, A., & Doiron, B. (2014). Formation and maintenance of neuronal assemblies through synaptic plasticity. Nature Communications, 5(1). https://doi.org/10.1038/ncomms6319
"""

LKD2014 = (
    AdEx = AdExParameter(
                        El = -70mV, 
                        Vt = -52.0mV, 
                        τm = 300pF /15.0nS, 
                        R = 1/(15.0nS),
                        Vr = -60.0f0mV,
                        τabs = 1ms,       
                        τri=0.5,
                        τdi=2.0,
                        τre=1.0,
                        τde=6.0,
                        E_i = -75mV,
                        E_e = 0mV,
                        At = 10mV
                        ),
    PV = IFParameter(
        El = -62.0mV,
        Vr = -57.47mV,   #(mV)
        Vt = -52.0mV,
        τm = 20ms,
        a = 0.0,
        b = 0.0,
        τw = 144,
        τri=0.5,
        τdi=2.0,
        τre=1.0,
        τde=6.0,
    )
)


export LKD2014
##
# IF = SNN.IF(; N = 1, param = LKD2014.PV)

# p2 = SNN.plot()
# SNN.monitor([IF], [:fire, :v])
# stim = SpikeTimeStimulus(1, IF, :ge, p=1.f0, param=inputs)
# sim!([IF],[SNN.EmptySynapse()], [stim], duration=1200ms, dt=0.1ms)
# p2 = SNN.vecplot!(p2, IF, :v, r=800:0.001:1200ms, neurons=[1], dt=0.1ms, label= IF.param.gsyn_e)

# SNN.monitor([IF], [:fire, :v])
# stim = SpikeTimeStimulus(1, IF, :gi, p=1.f0, param=inputs)
# sim!([IF],[SNN.EmptySynapse()], [stim], duration=1200ms, dt=0.1ms)
# p2 = SNN.vecplot!(p2, IF, :v, r=800:0.001:1200ms, neurons=[1], dt=0.1ms, label= IF.param.gsyn_i)
# SNN.plot!(p2, ylims=:auto)

# #
# IF = SNN.AdEx(; N = 1, param = LKD2014.AdEx)

# p3 = SNN.plot()
# SNN.monitor([IF], [:fire, :v])
# stim = SpikeTimeStimulus(1, IF, :ge, p=1.f0, param=inputs, μ=20)
# stim2 = CurrentStimulus(IF, I_base=100pA)
# sim!([IF],[SNN.EmptySynapse()], [stim,stim2], duration=1200ms, dt=0.1ms)
# p3 = SNN.vecplot!(p3, IF, :v, r=800:0.001:1200ms, neurons=[1], dt=0.1ms, label= IF.param.gsyn_e)

# SNN.monitor([IF], [:fire, :v])
# stim = SpikeTimeStimulus(1, IF, :gi, p=1.f0, param=inputs, μ=20)
# sim!([IF],[SNN.EmptySynapse()], [stim,stim2], duration=1200ms, dt=0.1ms)
# p3 = SNN.vecplot!(p3, IF, :v, r=800:0.001:1200ms, neurons=[1], dt=0.1ms, label= IF.param.gsyn_i)
# SNN.plot!(p3, ylims=:auto)

# #
# SNN.plot(p2, p3, legend=true,)
# ###