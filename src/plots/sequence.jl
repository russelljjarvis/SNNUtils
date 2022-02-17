## Plot sequence inputs
up_states = findall(x-> seq.sequence[1,x] == nn,1:100)
scatter(ones(60),up_states)
xs = [collect(5_0*(x-1).+(1:100:500)) for x in up_states]
ys = [n*ones(5) for n in eachindex(up_states)]
plot(hcat(xs...),hcat(ys...), label="", lw=10)
plot(xs,ys, label="", xlims=(1,20_000), lw=10)
