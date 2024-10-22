# istdp_dendrites(vd) = sISP(
#     η = 1.0, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
#     r0 = 0.01,  #target rate (khz)
#     vd = vd, #target dendritic potential
# )

# quaresima_istdp = istdp_dendrites(-70)

# lkd_istdp = sISP(
#     η = 1,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
#     r0 = 0.005,  #target rate (khz)
#     vd = -0.0f0, #target dendritic potential
# )

# duarte_istdp_lowrate = sISP(
#     #τy= 20, #decay of inhibitory rate trace (ms)
#     η = 1,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
#     r0 = 0.005,  #target rate (khz)
#     vd = -55.0f0, #target dendritic potential
# )

# duarte_istdp_highrate = sISP(
#     #τy= 20, #decay of inhibitory rate trace (ms)
#     η = 0.2,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
#     r0 = 0.01,  #target rate (khz)
#     vd = -70.0f0, #target dendritic potential
# )


# duarte_istdp = sISP(
#     #τy= 20, #decay of inhibitory rate trace (ms)
#     η = 1,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
#     r0 = 0.005,  #target rate (khz)
#     vd = -55.0f0, #target dendritic potential
# )


quaresima2023 = (
        iSTDP_rate = SNN.iSTDPParameterRate(η = 1., τy = 5ms, r=5Hz, Wmax = 273.4pF, Wmin = 0.1pF), 
        iSTDP_potential =SNN.iSTDPParameterPotential(η = 0.1, v0 = -70mV, τy = 200ms, Wmax = 273.4pF, Wmin = 0.1pF),        
        vstdp = SNN.vSTDPParameter(
                A_LTD = 4.0f-5,  #ltd strength          # made 10 times slower
                A_LTP = 14.0f-5, #ltp strength
                θ_LTD = -40.0,  #ltd voltage threshold # set higher
                θ_LTP = -20.0,  #ltp voltage threshold
                τu = 15.0,  #timescale for u variable
                τv = 45.0,  #timescale for v variable
                τx = 20.0,  #timescale for x variable
                Wmin = 1.78,  #minimum ee strength
                Wmax = 41.4,   #maximum ee strength
            )
    )