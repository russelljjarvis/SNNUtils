# Clopath 2010
struct STDP
      #voltage based stdp
      a⁻::Float64    #ltd strength (pF/mV) # a*(V-θ) = weight
      a⁺::Float64    #ltp strength (pF/mV)
      θ⁻::Float64 #ltd voltage threshold (mV)
      θ⁺::Float64 #ltp voltage threshold (mV)
      τu⁻::Float64  #timescale for u variable   (1/ms)
      τv⁻::Float64  #timescale for v variable   (1/ms)
      τx⁻::Float64  #timescale for x variable   (1/ms)
      ϵ::Float64  # filter for delayed membrane potential.
      j⁻::Float64  # minimum weight
      j⁺::Float64  # maximum weight

end

#Vogel 2011
#inhibitory stdp
struct ISTDP
      τy::Float64
      η::Float64
      r0::Float64
      α::Float64
      j⁻::Float64  # minimum weight
      j⁺::Float64  # maximum weight
end

struct TripletRule
      A⁺₂::Float64
      A⁺₃::Float64
      A⁻₂::Float64
      A⁻₃::Float64
      τˣ::Float64
      τʸ::Float64
      τ⁺::Float64
      τ⁻::Float64
end

# Gutig 2003
struct NLTAH
      τ::Float64
      λ::Float64
      μ::Float64
end

export NLTAH, ISTDP, STDP, TripletRule 
