function lkd_stdp()
      return STDP(
      a⁻ = 8.f-4pF/mV,  #ltd strength
      a⁺ = 14.f-4pF/mV, #ltp strength
      θ⁻ = -70.f0mV,  #ltd voltage threshold
      θ⁺ = -49.f0mV,  #ltp voltage threshold
      τu = 10.f0ms,  #timescale for u variable
      τv = 7.f0ms,  #timescale for v variable
      τx = 15.f0ms,  #timescale for x variable
      τ1 = 5ms,    # filter for delayed voltage
      j⁻ = 1.7f8pF,  #minimum ee strength
      j⁺ = 21.f4pF   #maximum ee strength
      )
end

function clopath_vstdp_visualcortex()
      return STDP(
      a⁻ = 14.f-3pF/mV,  #ltd strength
      a⁺ = 8.f-3pF/mV, #ltp strength
      θ⁻ = -70.6mV,  #ltd voltage threshold
      θ⁺ = -25.3mV,  #ltp voltage threshold
      τu = 10.0ms,  #timescale for u variable
      τv = 7.0ms,  #timescale for v variable
      τx = 15.0ms,  #timescale for x variable
      ϵ  = 1ms,    # filter for delayed voltage
      j⁻ = 1.78pF,  #minimum ee strength
      j⁺ = 21.4pF   #maximum ee strength
      )

end

function bono_vstdp()
      return STDP(
      a⁻ = 4.f-4pF/mV,  #ltd strength
      a⁺ = 14.f-4pF/mV, #ltp strength
      θ⁻ = -59.0mV,  #ltd voltage threshold
      θ⁺ = -20.0mV,  #ltp voltage threshold
      τu = 15.0ms,  #timescale for u variable
      τv = 45.0ms,  #timescale for v variable
      τx = 20.0ms,  #timescale for x variable
      τ1 = 5ms,    # filter for delayed voltage
      j⁻ = 1.78pF,  #minimum ee strength
      j⁺ = 21.4pF   #maximum ee strength
      )
end



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
