#
# enter results here
#
t_head_c = 100
t_pot_c = 100.6
isooctane_head = 45.8
isooctane_pot = 56.1
p_atmos = 750
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

# const Antoine = Dict(
#     "nheptane" => [154.62, -8793.1, -21.684, 0.023916, 1, 100.21],
#     "isooctane" => [120.81, -7550, -16.111, 0.017099, 1, 114.23]
# )


const Antoine = Dict(
    "nheptane_alt" => [6.9024, 1268.115, 216.9, 100.21],
    "isooctane_alt" => [6.81189, 1257.84, 220.74, 114.23] 
)


function print_antoine(molecule)
    s =  ['α':'γ'..., 'M'] 
    t = ""
    [t *= string(s[i]) * " = " * string(j) * "; " for (i, j) in enumerate(Antoine[molecule])]
    return strip(t)
end

kelvin(T) = T + KelvinOffset

function vapor(t, params, unit="mmHg")
    α, β, γ, M = params
    p = 10^(α - β / (t + γ))
    return p
end

function mole_fraction(wt_fract, MWS)
    mole1 = wt_fract / MWS[1]
    mole2 = (100 - wt_fract) / MWS[2]
    return 100 * mole1 / (mole1 + mole2)
end

isooctane_head_mole = mole_fraction(isooctane_head, [Antoine["isooctane_alt"][4], Antoine["nheptane_alt"][4]])
isooctane_pot_mole= mole_fraction(isooctane_pot, [Antoine["isooctane_alt"][4], Antoine["nheptane_alt"][4]])

α_head = vapor(t_head_c, Antoine["nheptane_alt"]) / vapor(t_head_c, Antoine["isooctane_alt"])
α_pot = vapor(t_pot_c, Antoine["nheptane_alt"]) / vapor(t_pot_c, Antoine["isooctane_alt"])
α_vol = √(α_head *  α_pot)

plates = -1 + log((100 - isooctane_head_mole) / (100 - isooctane_pot_mole) * isooctane_pot_mole / isooctane_head_mole) / log(α_vol)

plate_out = round(plates, digits=2)

print("Plate count: ", plate_out)

nhep = print_antoine("nheptane_alt")
isooct = print_antoine("isooctane_alt")




temp_range = 90:0.01:110
heptane_vp = vapor.(temp_range, Ref(Antoine["nheptane_alt"]))
isooctane_vp = vapor.(temp_range, Ref(Antoine["isooctane_alt"])) 

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