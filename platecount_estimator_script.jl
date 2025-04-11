#
# enter results here
#
t_head_c = 100
t_pot_c = 102
isooctane_head = 45
isooctane_pot = 56
p_atmos = 760
#
# enter results here
#

using Plots

const KelvinOffset = 273.15

const Pressure = Dict(
    "Pa" => 1.0,
    "atm" => 9.8692e-6,
    "psi" => 0.000145038,
    "mmHg" => 0.0075,
    "kPa" => 1e-3,
    "hPa" => 1e-2,
    "mbar" => 1e-2,
    "bar" => 1e-5)

const Antoine = Dict(
    "nheptane" => [154.62, -8793.1, -21.684, 0.023916, 1],
    "isooctane" => [120.81, -7550, -16.111, 0.017099, 1]
)

function print_antoine(molecule)
    s =  'α' :'ε'  
    t = ""
    [t *= string(s[i]) * " = " * string(j) * "; " for (i, j) in enumerate(Antoine[molecule])]
    return strip(t)
end

kelvin(T) = T + KelvinOffset

function vapor(t, params, unit="mmHg")
    α, β, γ, δ, ε = params
    p = exp(α + β / t + γ * log(t) + δ * t^ε) * Pressure[unit]
    return p
end

α_head = vapor(kelvin(t_head_c), Antoine["nheptane"]) / vapor(kelvin(t_head_c), Antoine["isooctane"])
α_pot = vapor(kelvin(t_pot_c), Antoine["nheptane"]) / vapor(kelvin(t_pot_c), Antoine["isooctane"])
α_vol = √(α_head *  α_pot)

plates = -1 + log((100 - isooctane_head) / (100 - isooctane_pot) * isooctane_pot / isooctane_head) / log(α_vol)

plate_out = round(plates, digits=2)

print("Plate count: ", plate_out)

nhep = print_antoine("nheptane")
isooct = print_antoine("isooctane")




temp_range = 90:0.01:110
heptane_vp = vapor.(kelvin.(temp_range), Ref(Antoine["nheptane"]))
isooctane_vp = vapor.(kelvin.(temp_range), Ref(Antoine["isooctane"]))

# approximate boiling points at pressure
h = temp_range[minimum(findall(heptane_vp .> p_atmos))]
o = temp_range[minimum(findall(isooctane_vp .> p_atmos))]


plot(
    temp_range, heptane_vp,
    legend=false, color=:red,
    title="Vapor pressure of n-heptane and iso-octane",
    xaxis="Temperature (°C)", yaxis="Vapor pressure (mmHg)"
)
plot!(temp_range, isooctane_vp, legend=false, color=:blue)
hline!([p_atmos p_atmos], linestyle=:dash, color=:gray)
annotate!(92, p_atmos, ("Pressure\n" * string(p_atmos) * " mmHg", :center, 8))
annotate!(h, p_atmos + 25, ("n-heptane\n" * string(h) * "°C", :red, 8, :right))
annotate!(o, p_atmos - 25, ("iso-octane\n" * string(o) * "°C", :blue, 8, :left))