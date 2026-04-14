library(shiny)
library(tidyverse)

# Define UI
ui <- fluidPage(
    titlePanel("Plate Count Estimator"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("t_head", "Head Temperature (°C)", min = 90, max = 110, value = 100, step = 0.1),
            sliderInput("t_pot", "Pot Temperature (°C)", min = 90, max = 110, value = 100.6, step = 0.1),
            sliderInput("isooctane_head", "Head Isooctane Composition (%)", min = 0, max = 100, value = 45.8, step = 0.1),
            sliderInput("isooctane_pot", "Pot Isooctane Composition (%)", min = 0, max = 100, value = 56.1, step = 0.1),
            sliderInput("p_atmos", "Atmospheric Pressure (mmHg)", min = 700, max = 800, value = 750, step = 1)
        ),
        mainPanel(
            textOutput("plate_count"),
            plotOutput("vp_plot")
        )
    )
)

# Define server
server <- function(input, output) {
    # Constants and functions from original script
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
    
    output$plate_count <- renderText({
        alpha_head <- vapor(kelvin(input$t_head), Antoine$nheptane) /
            vapor(kelvin(input$t_head), Antoine$isooctane)
        alpha_pot <- vapor(kelvin(input$t_pot), Antoine$nheptane) /
            vapor(kelvin(input$t_pot), Antoine$isooctane)
        alpha_vol <- sqrt(alpha_head * alpha_pot)
        
        Mw <- c(Antoine$isooctane[6], Antoine$nheptane[6])
        isooctane_head_mole <- mole_fraction(input$isooctane_head, Mw)
        isooctane_pot_mole <- mole_fraction(input$isooctane_pot, Mw)
        
        plates <- -1 + log((100 - isooctane_head_mole) / (100 - isooctane_pot_mole) *
            isooctane_pot_mole / isooctane_head_mole) / log(alpha_vol)
        paste("Plate count:", round(plates, 2))
    })
    
    output$vp_plot <- renderPlot({
        temp_range <- seq(90, 110, by = 0.01)
        heptane_vp <- vapor(kelvin(temp_range), Antoine$nheptane)
        isooctane_vp <- vapor(kelvin(temp_range), Antoine$isooctane)
        
        h <- temp_range[which(heptane_vp > input$p_atmos)[1]]
        o <- temp_range[which(isooctane_vp > input$p_atmos)[1]]
        
        plot_data <- tibble(
            temperature = temp_range,
            heptane = heptane_vp,
            isooctane = isooctane_vp
        ) %>%
            pivot_longer(c(heptane, isooctane), names_to = "compound", values_to = "pressure")
        
        plot_data %>%
            ggplot(aes(x = temperature, y = pressure, color = compound)) +
            geom_line(linewidth = 1) +
            geom_hline(yintercept = input$p_atmos, linetype = "dashed", color = "gray50") +
            annotate("text",
                x = 92, y = input$p_atmos, label = paste0("Pressure\n", input$p_atmos, " mmHg"),
                hjust = 0, size = 3
            ) +
            annotate("text",
                x = h, y = input$p_atmos + 25,
                label = paste0("n-heptane\n", h, "°C"), color = "red", hjust = 1, size = 3
            ) +
            annotate("text",
                x = o, y = input$p_atmos - 25,
                label = paste0("iso-octane\n", o, "°C"), color = "blue", hjust = 0, size = 3
            )
    })
}

# Run the app
shinyApp(ui = ui, server = server)