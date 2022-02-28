
function vogels_istdp()
      ## Inhibition
      tauy = 20.0 #decay of inhibitory rate trace (ms)
      eta = 1.0   #istdp learning rate    (pF⋅ms) eta*rate = weights
      r0 = .005   #target rate (khz)
      alpha = 2*r0*tauy; #rate trace threshold for istdp sign (kHz) (so the 2 has a unit)
      jeimin = 48.7 #minimum ei strength (pF)
      jeimax = 243 #maximum ei strength   (pF)

      return ISTDP(tauy, eta, r0, alpha, jeimin, jeimax)
end

istdp = vogels_istdp()
