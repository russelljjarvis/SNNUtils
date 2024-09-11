
# Clopath 2010
@with_kw struct STDP
    #voltage based stdp
    a⁻::Float32 = 0.0f0    #ltd strength (pF/mV) # a*(V-θ) = weight
    a⁺::Float32 = 0.0f0    #ltp strength (pF/mV)
    θ⁻::Float32 = -90.0f0 #ltd voltage threshold (mV)
    θ⁺::Float32 = 0.0f0 #ltp voltage threshold (mV)
    τs::Float32 = 20 # homeostatic scaling timescale
    τu::Float32 = 1.0f0  #timescale for u variable   (1/ms)
    τv::Float32 = 1.0f0  #timescale for v variable   (1/ms)
    τx::Float32 = 1.0f0  #timescale for x variable   (1/ms)
    τ1::Float32 = 1.0f0
    ϵ::Float32 = 1.0f0  # filter for delayed membrane potential.
    j⁻::Float32 = 0.0f0 # minimum weight
    j⁺::Float32 = 100.0f0 # maximum weight
    τu⁻::Float32 = 1 / τu  #timescale for u variable   (1/ms)
    τv⁻::Float32 = 1 / τv  #timescale for v variable   (1/ms)
    τx⁻::Float32 = 1 / τx  #timescale for x variable   (1/ms)
    τ1⁻::Float32 = 1 / τ1

end

#Vogel 2011
#inhibitory stdp
@with_kw struct ISTDP
    ## sISP
    η::Float32 = 0.2
    r0::Float32 = 0.01
    vd::Float32 = -70
    τd::Float64 = 5 #decay of dendritic potential (ms)
    τy::Float32 = 20 #decay of inhibitory rate trace (ms)
    α::Float32 = 2 * r0 * τy
    j⁻::Float32 = 2.78f0  # minimum weight
    j⁺::Float32 = 243.0f0 # maximum weight
    # ## vISP
    # ηv::Float32=10e-3 ## learning rate
    # θv::Float32=-65 ## threshold for voltage
    # αv::Float32=2*10e-4 ## depression parameter
    # τv::Float32=5 ## decay of inhibitory rate trace (ms)
    # τs::Float32=200ms ## decay of inhibitory rate trace (ms)
end
vISP = ISTDP
sISP = ISTDP



struct TripletRule
    A⁺₂::Float32
    A⁺₃::Float32
    A⁻₂::Float32
    A⁻₃::Float32
    τˣ::Float32
    τʸ::Float32
    τ⁺::Float32
    τ⁻::Float32
    # τˣ⁻::Float32
    # τʸ⁻::Float32
    # τ⁺⁻::Float32
    # τ⁻⁻::Float32
end

# Gutig 2003
struct NLTAH
    τ::Float32
    λ::Float32
    μ::Float32
end

export NLTAH, ISTDP, STDP, TripletRule


istdp_dendrites(vd) = sISP(
    η = 1.0, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
    r0 = 0.01,  #target rate (khz)
    vd = vd, #target dendritic potential
)

quaresima_istdp = istdp_dendrites(-70)

lkd_istdp = sISP(
    η = 1,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
    r0 = 0.005,  #target rate (khz)
    vd = -0.0f0, #target dendritic potential
)

duarte_istdp_lowrate = sISP(
    #τy= 20, #decay of inhibitory rate trace (ms)
    η = 1,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
    r0 = 0.005,  #target rate (khz)
    vd = -55.0f0, #target dendritic potential
)

duarte_istdp_highrate = sISP(
    #τy= 20, #decay of inhibitory rate trace (ms)
    η = 0.2,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
    r0 = 0.01,  #target rate (khz)
    vd = -70.0f0, #target dendritic potential
)


duarte_istdp = sISP(
    #τy= 20, #decay of inhibitory rate trace (ms)
    η = 1,#0.20, #was 1. #istdp learning rate    (pF⋅ms) eta*rate = weights
    r0 = 0.005,  #target rate (khz)
    vd = -55.0f0, #target dendritic potential
)
