library(tidyverse)

# input values
t_head_c <- 100
t_pot_c <- 100.6
isooctane_head <- 45.8
isooctane_pot <- 56.1
p_atmos <- 750

KelvinOffset <- 273.15
Pressure <- c(
    Pa = 1.0,
    atm = 9.8692e-6,
    psi = 0.000145038,
    mmHg = 0.0075,
    kPa = 1e-3,
    hPa = 1e-2,
    mbar = 1e-2,
    bar = 1e-5
)

Antoine <- list(
    nheptane = c(154.62, -8793.1, -21.684, 0.023916, 1, 100.21),
    isooctane = c(120.81, -7550, -16.111, 0.017099, 1, 114.23)
)

print_antoine <- function(molecule) {
    symbols <- c("α", "β", "γ", "δ", "ε", "M")
    params <- Antoine[[molecule]]
    paste0(symbols, " = ", params, collapse = "; ")
}

kelvin <- function(T) T + KelvinOffset

vapor <- function(t, params, unit = "mmHg") {
    α <- params[1]
    β <- params[2]
    γ <- params[3]
    δ <- params[4]
    ε <- params[5]
    exp(α + β / t + γ * log(t) + δ * t^ε) * Pressure[[unit]]
}

mole_fraction <- function(wt_fraction, Mw) {
    mole1 <- wt_fraction / Mw[1]
    mole2 <- (100 - wt_fraction) / Mw[2]
    100 * mole1 / (mole1 + mole2)
}

alpha_head <- vapor(kelvin(t_head_c), Antoine$nheptane) /
    vapor(kelvin(t_head_c), Antoine$isooctane)
alpha_pot <- vapor(kelvin(t_pot_c), Antoine$nheptane) /
    vapor(kelvin(t_pot_c), Antoine$isooctane)
alpha_vol <- sqrt(alpha_head * alpha_pot)

Mw <- c(Antoine$isooctane[6], Antoine$nheptane[6])
isooctane_head_mole <- mole_fraction(isooctane_head, Mw)
isooctane_pot_mole <- mole_fraction(isooctane_pot, Mw)

plates <- -1 + log((100 - isooctane_head_mole) / (100 - isooctane_pot_mole) *
    isooctane_pot_mole / isooctane_head_mole) / log(alpha_vol)
plate_out <- round(plates, 2)

cat("Plate count:", plate_out, "\n")

nhep <- print_antoine("nheptane")
isooct <- print_antoine("isooctane")

cat("n-heptane Antoine params:", nhep, "\n")
cat("iso-octane Antoine params:", isooct, "\n")

temp_range <- seq(90, 110, by = 0.01)
heptane_vp <- vapor(kelvin(temp_range), Antoine$nheptane)
isooctane_vp <- vapor(kelvin(temp_range), Antoine$isooctane)

h <- temp_range[which(heptane_vp > p_atmos)[1]]
o <- temp_range[which(isooctane_vp > p_atmos)[1]]

plot_data <- tibble(
    temperature = temp_range,
    heptane = heptane_vp,
    isooctane = isooctane_vp
) %>%
    pivot_longer(c(heptane, isooctane), names_to = "compound", values_to = "pressure")

plot_data %>%
    ggplot(aes(x = temperature, y = pressure, color = compound)) +
    geom_line(size = 1) +
    geom_hline(yintercept = p_atmos, linetype = "dashed", color = "gray50") +
    annotate("text",
        x = 92, y = p_atmos, label = paste0("Pressure\n", p_atmos, " mmHg"),
        hjust = 0, size = 3
    ) +
    annotate("text",
        x = h, y = p_atmos + 25,
        label = paste0("n-heptane\n", h, "°C"), color = "red", hjust = 1, size = 3
    ) +
    annotate("text",
        x = o, y = p_atmos - 25,
        label = paste0("iso-octane\n", o, "°C"), color = "blue", hjust = 0, size = 3
    ) +
    scale_color_manual(
        values = c(heptane = "red", isooctane = "blue"),
        labels = c(heptane = "n-heptane", isooctane = "iso-octane")
    ) +
    labs(
        title = "Vapor pressure of n-heptane and iso-octane",
        x = "Temperature (°C)",
        y = "Vapor pressure (mmHg)",
        color = "Compound"
    ) +
    theme_minimal()
