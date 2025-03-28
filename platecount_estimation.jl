### A Pluto.jl notebook ###
# v0.20.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 62a783e5-71ee-4980-8a31-33d8a3e09587
using PlutoUI

# ╔═╡ ed4cba20-0b16-11f0-2ac4-f122ce444b47
md"# Determining the plate count of a distillation column"

# ╔═╡ aecb2f08-c6b7-4ac9-8684-59ca0c7ecf8f
md"## Plate estimation"

# ╔═╡ 936d93db-bc2f-484f-8a17-2a837a799a05
begin
	pressure = (mmHg = 0.0075, Pa = 1)
	nheptane = [154.62, -8793.1, -21.684, 0.023916, 1]
	isooctane = [120.81, -7550, -16.111, 0.017099, 1]
	
	kelvin(t) = t + 273.15
	
	function vapor(t, params, unit = "mmHg")
		A, B, C, D, E = params
		p = exp(A + B / t + C * log(t) + D * t^E)
		if unit == "mmHg" p = p * pressure.mmHg end
		return p
	end	
end

# ╔═╡ a8270580-1957-4dea-9834-349ccd33f88a
md"Iso-octane concentration (pot): $(@bind isooctane_pot Slider(0.0:0.1:100.0, 54.3, true))"

# ╔═╡ a0a38b61-cacf-40be-a0a1-567f41a878ff
md"Iso-octane concentration (head): $(@bind isooctane_head Slider(0.0:0.1:100, 37.60, true))"

# ╔═╡ f25fe5fa-0120-4bd8-9e15-f1742849b411
md"Temperature (pot, C): $(@bind t_pot_c Slider(80.0:0.1:120, 100.0, true))"

# ╔═╡ b2c9e66e-7cdd-4235-b3c5-ff9fb42d8dd8
md"Temperature (head, C): $(@bind t_head_c Slider(80.0:0.1:120, 100.0, true))"

# ╔═╡ d7287640-d44a-43a9-af5f-d9fa6450424c
begin
	rel_vol_head = vapor(kelvin(t_head_c), nheptane) / vapor(kelvin(t_head_c), isooctane)
	rel_vol_pot = vapor(kelvin(t_pot_c), nheptane) / vapor(kelvin(t_pot_c), isooctane)
	rel_vol = √(rel_vol_head * rel_vol_pot)
	plates = -1 + log((100-isooctane_head) / (100-isooctane_pot) * isooctane_pot / isooctane_head) / log(rel_vol)
	print("Plate count: ", round(plates, digits = 2))
end

# ╔═╡ 353aed41-ac18-4e2f-ba49-840fdf294918
md"## Background"

# ╔═╡ 0c6faaba-4c7e-4017-b69b-1c172fa597bd
md"### Plate count estimation"

# ╔═╡ 0a54a983-42ee-4d2f-a10a-d3d304b4662d

md"The number of plates in a column can be calculated from distilling a mixture of iso-octane and n-heptane. The plate count can be estimated via Fenske's equation $^{[1-2]}$:

$N = \frac{log(\frac{C_{nheptane}^{head}}{C_{nheptane}^{pot}} \times \frac{C_{isooctane}^{pot}}{C_{isooctane}^{head}})}{log(\alpha_{avg})} - 1$

where $\alpha_{avg}$ is the average relative volatility of the components, calculated by 

$\alpha = \frac{p_{nheptane}}{p_{isooctane}}$

IF the $\alpha$ changes throughout the column due to *e.g.* difference in temperatures, $\alpha_{avg}$ can be approximated by taking the geometric average

$\alpha_{avg} = \sqrt{\alpha_{pot} \times \alpha_{head}}$
"

# ╔═╡ 718ff008-f066-41cf-84d7-4d1021100b57
md"### Vapor pressure estimation"

# ╔═╡ af9fad7e-3375-4844-bb62-7212f1814156
md"Vapor pressure of a liquid can be modelled by a modified VLE expression." 

# ╔═╡ fe317b49-fccf-48c0-a1c3-ab407fe9ac77
md" $log(p) = A + \frac{B}{T} + C \times log(T) + D \times T^E$"

# ╔═╡ 7583d8f3-4953-4dba-97b7-65373036f197
md"where $p$ is pressure, $T$ is is temperature in Kelvin and $A$ through $E$ are empirical parameters.$^{[3]}$"

# ╔═╡ 86d8b77c-085d-4986-806d-ec99ec7e2292
begin
md"For n-heptane these parameters are: A = 154.62, B = -8793.1, C = -21.684, D = 0.023916, E = 1
	
For iso-octane these parameters are: A = 120.81, B = -7550, C = -16.111, D = 0.017099, E = 1
"
end

# ╔═╡ 3513eac3-98b6-49ef-b727-3ee3f60ffc94
md"## References"

# ╔═╡ 7b2d9351-4144-4c21-811c-ebc5f1b91934
md"
[1] Fenske, Ind. Eng. Chem., 24, 482 (1932).

[2] Gilliland, Ind. Eng. Chem., 32(9), 1220 (1940)

[3] ChemCad 5.00 Library"



# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.62"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.3"
manifest_format = "2.0"
project_hash = "8ee5d63d41e3e4bb137628ac5343048da171f71e"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "d3de2694b52a01ce61a036f18ea9c0f61c4a9230"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.62"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─ed4cba20-0b16-11f0-2ac4-f122ce444b47
# ╟─aecb2f08-c6b7-4ac9-8684-59ca0c7ecf8f
# ╟─62a783e5-71ee-4980-8a31-33d8a3e09587
# ╟─936d93db-bc2f-484f-8a17-2a837a799a05
# ╟─a8270580-1957-4dea-9834-349ccd33f88a
# ╟─a0a38b61-cacf-40be-a0a1-567f41a878ff
# ╟─f25fe5fa-0120-4bd8-9e15-f1742849b411
# ╟─b2c9e66e-7cdd-4235-b3c5-ff9fb42d8dd8
# ╟─d7287640-d44a-43a9-af5f-d9fa6450424c
# ╟─353aed41-ac18-4e2f-ba49-840fdf294918
# ╟─0c6faaba-4c7e-4017-b69b-1c172fa597bd
# ╟─0a54a983-42ee-4d2f-a10a-d3d304b4662d
# ╟─718ff008-f066-41cf-84d7-4d1021100b57
# ╟─af9fad7e-3375-4844-bb62-7212f1814156
# ╟─fe317b49-fccf-48c0-a1c3-ab407fe9ac77
# ╟─7583d8f3-4953-4dba-97b7-65373036f197
# ╟─86d8b77c-085d-4986-806d-ec99ec7e2292
# ╟─3513eac3-98b6-49ef-b727-3ee3f60ffc94
# ╟─7b2d9351-4144-4c21-811c-ebc5f1b91934
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
