# MTB Multitasking Analysis

Comprehensive analysis of car-motorbike interactions at urban intersections, examining driver decision-making when encountering motorcycles and traffic lights in busy urban environments.

## 📋 Project Overview

This project studies how drivers interact with motorcycles at various intersection types in urban driving scenarios. We analyze high-frequency driving simulation data to understand behavioral patterns, safety decisions, and compliance with traffic rules during car-motorbike encounters.

## 🏙️ Scenario Description

Participants drive through a busy urban environment encountering motorcycles at multiple intersections. The scenario tests:
- **Give-way decisions** when motorcycles are present
- **Traffic light compliance** when approaching amber lights
- **Speed and lateral stability** during urban driving
- **Following behavior** when behind other vehicles

## 🛑 Intersection Types Analyzed

### Motorbike Give-Way Intersections
- **Intersection 1, 2, 4, 7, 10, 15**: Driver has option to give way to motorcycle
  - `1` = Driver waited for motorcycle
  - `0` = Driver did not wait

### Traffic Light Intersections  
- **Intersection 6, 14**: Lights turn amber as driver approaches
  - `>0` = Driver stopped at light
  - `0` = Driver ran the light

## 🔬 Research Questions

1. **Safety Compliance**: What percentage of drivers give way to motorcycles at intersections?
2. **Traffic Law Adherence**: How often do drivers run amber lights vs. stopping safely?
3. **Individual Differences**: Are there consistent patterns in driver behavior across intersections?
4. **Driving Quality**: How do intersection encounters affect speed stability and lateral position?
5. **Following Behavior**: How do drivers maintain headway in urban traffic conditions?

## 📊 Data Structure

- **Sampling Rate**: 0.05-second intervals (20 Hz)
- **File Format**: Tab-separated CSV with complex column names
- **Participants**: Multiple drivers through urban scenario
- **Metrics**: Speed, lateral position, headway, intersection behavior

## 🚀 Quick Start

### Prerequisites
- R (4.0+) with tidyverse
- RStudio or Positron IDE

### Running Analysis

```r
# Open the R project
# File → Open Project → mtb_multitasking.Rproj

# Load the analysis functions
source("R/mtb_multitasking.R")

# For single file analysis
result <- analyze_mtb_multitasking("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")

# For batch processing
summary <- process_mtb_multitasking_batch("data/raw/")
```

### Expected Data Format
```
MBInt-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```
**Example**: `MBInt-29_07_2025-11h10m06s_4212.csv`

## 📁 Project Structure

```
mtb_multitasking/
├── R/
│   └── mtb_multitasking.R       # Main analysis functions
├── data/raw/                    # Raw CSV files (excluded from git)
├── output/                      # Summary CSV files  
├── docs/                        # Documentation
│   └── mtb_multitasking.md     # Detailed usage guide
├── mtb_multitasking.Rproj      # R project file
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## 📈 Key Metrics Calculated

### Driving Behavior
- **Speed**: Average, SD, min, max throughout scenario
- **SDLP**: Standard Deviation of Lateral Position (stability indicator)
- **Following**: Headway distance and time when behind vehicles

### Intersection Behavior
- **Motorbike Give-Way**: Binary compliance at 6 intersections
- **Traffic Light**: Compliance vs. running amber lights
- **Compliance Rates**: Overall percentages for safety analysis

### Output Summary
- **Individual Analysis**: Detailed console output per participant
- **Batch Summary**: CSV file ready for statistical analysis
- **Compliance Metrics**: Safety and rule-following indicators

## 🎯 Usage Examples

### Single Participant Analysis
```r
# Analyze one driver's behavior
result <- analyze_mtb_multitasking("data/raw/MBInt-29_07_2025-11h10m06s_4212.csv")

# View driving metrics
result$summary_metrics$avg_speed
result$summary_metrics$sdlp

# Check intersection compliance
result$summary_metrics$int_1_gave_way  # 1 = gave way, 0 = didn't wait
result$summary_metrics$int_6_stopped_at_light  # >0 = stopped, 0 = ran light
```

### Batch Processing
```r
# Process all participants
summary_data <- process_mtb_multitasking_batch("data/raw/")

```

## 📄 Documentation

- **[Detailed Usage Guide](docs/mtb_multitasking.md)**: Complete setup and analysis instructions
- **[Function Reference](R/mtb_multitasking.R)**: Comprehensive code documentation
- **Troubleshooting**: Common issues and solutions

## 🤝 Contributing

This project follows lab coding standards:
- Use tidyverse conventions for data manipulation
- Include comprehensive error handling
- Document all functions thoroughly  
- Provide clear usage examples
- Filter unrealistic values (e.g., 99000 placeholders)

## 📧 Contact

Alan Sims - alan.sims@griffithuni.edu.au

**Repository**: https://github.com/alan-sims/traffic_psychology

---

*Part of the Traffic Psychology Lab research portfolio*
