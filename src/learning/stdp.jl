function lkd_stdp()
      altd = .0008 #ltd strength (pF/mV) # a*(V-θ) = weight
      altp = .0014 #ltp strength (pF/mV)
      # thetaltd = -70.0 #ltd voltage threshold (mV)
      # thetaltp = -49.0 #ltp voltage threshold (mV)
      thetaltd = -70.0 #ltd voltage threshold (mV)
      thetaltp = -49.0 #ltp voltage threshold (mV)

      tauu = 10.0 #timescale for u variable   (ms)
      tauv = 7.0  #timescale for v variable   (ms)
      taux = 15.0 #timescale for x variable   (ms)
      tau1    = 5.   # filter for delayed voltage

      jeemin = 1.78 #minimum ee strength (pF)  pF/ms = nS #xerise/difEtau = ge
      jeemax = 21.4 #maximum ee strength (pF)
      return STDP(altd, altp, thetaltd, thetaltp, 1/tauu, 1/tauv, 1/taux, 1/tau1, jeemin, jeemax)
end

function clopath_vstdp_visualcortex()
      altd = 14e-5/2.5 #ltd strength (pF/mV) # a*(V-θ) = weight
      altp = 8e-5/2.5 #ltp strength (pF/mV)
      thetaltd = -70.6 #ltd voltage threshold (mV)
      thetaltp = -25.3 #ltp voltage threshold (mV)

      tauu = 10.0 #timescale for u variable   (ms) τ⁻
      tauv = 7.0  #timescale for v variable   (ms) τ⁺
      taux = 15.0 #timescale for x variable   (ms)
      ϵ    = 1.   # filter for delayed voltage

      jeemin = 1.78 #minimum ee strength (pF)  pF/ms = nS #xerise/difEtau = ge
      jeemax = 21.4 #maximum ee strength (pF)

      return STDP(altd, altp, thetaltd, thetaltp, 1/tauu, 1/tauv, 1/taux, ϵ, jeemin, jeemax)

end

function bono_vstdp()
      altd = 4.f-4 #ltd strength (pF/mV) # a*(V-θ) = weight
      altp = 14.f-4 #ltp strength (pF/mV)
      thetaltd = -59.0 #ltd voltage threshold (mV)
      thetaltp = -20.0 #ltp voltage threshold (mV)

      tauu = 15.0 #timescale for u variable   (ms) τ⁻
      tauv = 45.0  #timescale for v variable   (ms) τ⁺
      taux = 20.0 #timescale for x variable   (ms)
      tau1 = 5.   # filter for delayed voltage

      jeemin = 1.78 #minimum ee strength (pF)  pF/ms = nS #xerise/difEtau = ge
      jeemax = 21.4 #maximum ee strength (pF)

      return STDP(altd, altp, thetaltd, thetaltp, 1/tauu, 1/tauv, 1/taux, 1/tau1, jeemin, jeemax)

end

soma_stdp  = lkd_stdp()
dend_stdp  = bono_vstdp()
bono_stdp  = bono_vstdp()





function pfister_visualcortex(alltoall::Bool=true, full::Bool=true)
      if alltoall
            if full
                  return TripletRule(5e-10, 6.2e-3, 7e-3, 2.3e-4, 101., 125., 16.8, 33.7)
            else
                  return TripletRule(0., 6.5e-3, 7.1e-3, 0., -1., 125., 16.8, 33.7)
            end
      else
            if full
                  return TripletRule(8.8e-11, 5.3e-2, 6.6e-3, 3.1e-3, 714., 40., 16.8, 33.7 )
            else
                  return TripletRule(0., 5.2e-2, 8.e-3, 0., -1., 40., 16.8, 33.7 )
            end
      end
end
