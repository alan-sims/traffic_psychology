# MTB Filtering Analysis

## 📋 Project Overview

This project analyzes driver behavior and awareness during motorcycle filtering scenarios in heavy traffic conditions. The study investigates how drivers detect, respond to, and are physiologically affected by motorcycles performing lane filtering/splitting maneuvers at different speeds and positions.

## 🏙️ Scenario Description

Participants drive on a **2-lane each way motorway** experiencing heavy **stop-start traffic**. During the drive:

- **Every 30 seconds**: A motorcycle passes the stationary/slow-moving traffic
- **Two filtering positions** (within-subjects):
  - **Middle filtering**: Motorcycle passes between the two lanes of traffic
  - **Side filtering**: Motorcycle passes along the side of traffic
- **Two speed conditions** (between-subjects):
  - **Legal filtering**: Motorcycle travels at 30km/h (legal filtering speed)
  - **Illegal filtering**: Motorcycle travels at 90km/h (excessive speed)

### Experimental Conditions
1. **Legal Middle** - 30km/h filtering between lanes
2. **Legal Side** - 30km/h filtering along traffic side  
3. **Illegal Middle** - 90km/h filtering between lanes
4. **Illegal Side** - 90km/h filtering along traffic side

## 🔬 Research Questions

This study aims to investigate:

1. **Detection & Awareness**: Do drivers notice motorcycles filtering at different speeds and positions?
2. **Physiological Response**: How do filtering speed and position affect driver stress/arousal?
3. **Behavioral Adaptation**: Do drivers modify their driving behavior when motorcycles are present?
4. **Speed vs Position Effects**: Which factor (filtering speed or position) has greater impact on driver responses?
5. **Individual Differences**: Are some drivers more sensitive to motorcycle filtering than others?

### Multi-Modal Data Collection
- **Driving Behavior**: Speed, lateral position, following distance (this analysis)
- **Eye-Tracking**: Visual attention and motorcycle detection patterns
- **Physiological**: Stress responses via HexoSkin sensors
- **Attitudes**: Knowledge and opinions about motorcycle filtering laws

## 📊 Data Structure

**File Format**: Tab-separated CSV with 6 columns  
**Sampling Rate**: 0.05-second intervals (20 Hz)  
**Duration**: Variable based on traffic scenario completion

### Column Structure
```
time | speed | headway_distance | lateral_shift | braking | time_headway
```

**Key Data Handling**:
- **99000 values**: Default placeholders when no vehicle ahead (filtered out in analysis)
- **"null" strings**: Converted to proper NA values
- **Realistic filtering**: Headway >500m and time headway >30s treated as invalid

## 🚀 Quick Start

### Prerequisites
- R (4.0+) with tidyverse
- RStudio or Positron IDE

### Running Analysis

```r
# Load the analysis functions
source("R/mtb_filtering.R")

# For single file analysis
result <- analyze_mtb_filtering("data/raw/Motorcycles_100kph_Legal_Filtering_Middle_Lane-02_05_2025-12h40m02s_9898.csv")

# For batch processing all files
summary <- process_mtb_filtering_batch("data/raw/")
```

### Expected Data Format
```
Motorcycles_100kph_[Legal/Illegal]_Filtering_[Position]-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```

**Examples**:
- `Motorcycles_100kph_Legal_Filtering_Middle_Lane-07_05_2025-11h37m58s_2368.csv`
- `Motorcycles_100kph_Illegal_Filtering_Right_Left_Side-08_04_2025-16h48m14s_0706.csv`

## 📁 Project Structure

```
mtb_filtering/
├── R/
│   └── mtb_filtering.R          # Main analysis functions
├── data/raw/                    # Raw CSV files (excluded from git)
├── output/                      # Summary CSV files  
│   └── mtb_filtering_summary.csv # Batch processing results
├── docs/                        # Documentation
│   └── mtb_filtering.md         # Detailed usage guide
├── mtb_filtering.Rproj          # R project file
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## 📈 Key Metrics Calculated

### Driving Behavior Metrics
- **Speed**: Mean, SD, min, max throughout scenario
- **SDLP**: Standard Deviation of Lateral Position (stability/stress indicator)
- **Following Behavior**: Headway distance and time when behind vehicles (realistic values only)

### Traffic-Specific Metrics
- **Duration**: Time spent in stop-start traffic scenario
- **Observations**: Data points collected per participant
- **Data Quality**: Percentage of valid vs. placeholder data

### Expected Behavioral Patterns
- **Illegal filtering**: Higher SDLP (increased stress/awareness)
- **Middle filtering**: Potentially stronger responses than side filtering
- **Speed effects**: 90km/h motorcycles may cause more dramatic behavioral changes
- **Individual differences**: Variation in sensitivity to motorcycle presence

## 🎯 Usage Examples

### Single Participant Analysis
```r
# Analyze one driver's response to motorcycle filtering
result <- analyze_mtb_filtering("data/raw/Motorcycles_100kph_Illegal_Filtering_Middle_Lane-01_04_2025-18h12m43s_1402.csv")

# View behavioral metrics
result$metrics$mean_speed          # Average driving speed
result$metrics$sd_lateral_shift    # SDLP (stress/stability indicator)
result$metrics$mean_headway_distance # Following distance behavior
```

### Batch Processing & Condition Comparison
```r
# Process all participants
summary_data <- process_mtb_filtering_batch("data/raw/")

# Compare conditions
library(tidyverse)

# Speed effects (Legal vs Illegal)
summary_data %>%
  group_by(condition) %>%
  summarise(
    mean_speed = mean(mean_speed, na.rm = TRUE),
    mean_sdlp = mean(sd_lateral_shift, na.rm = TRUE)
  )

# Position effects (Middle vs Side)
summary_data %>%
  mutate(position = ifelse(grepl("Middle", condition), "Middle", "Side")) %>%
  group_by(position) %>%
  summarise(avg_sdlp = mean(sd_lateral_shift, na.rm = TRUE))
```

## 🔬 Integration with Multi-Modal Data

This driving behavior analysis is designed to integrate with:

### Eye-Tracking Analysis
- **Motorcycle detection events**: When/if drivers visually notice filtering motorcycles
- **Attention patterns**: Looking behavior during filtering events
- **Detection vs. behavior**: Correlation between noticing and behavioral response

### Physiological Analysis (HexoSkin)
- **Stress responses**: Heart rate/skin conductance during motorcycle encounters
- **Anticipatory responses**: Physiological changes before behavioral changes
- **Recovery patterns**: How quickly drivers return to baseline after filtering events

### Statistical Analysis Pipeline
```r
# Example: Combine behavioral and eye-tracking data
behavioral_data <- process_mtb_filtering_batch("data/raw/")
# eyetracking_data <- process_eyetracking_batch("eyetracking/raw/")
# physiological_data <- process_hexoskin_batch("physiological/raw/")

# Multi-modal analysis
# combined_analysis <- merge_multimodal_data(behavioral_data, eyetracking_data, physiological_data)
```

## 📄 Documentation

- **[Detailed Usage Guide](docs/mtb_filtering.md)**: Complete setup and analysis instructions
- **[Function Reference](R/mtb_filtering.R)**: Comprehensive code documentation
- **Troubleshooting**: Common issues and solutions

## 🤝 Contributing

This project follows lab coding standards:
- Use tidyverse conventions for data manipulation
- Include comprehensive error handling for 99000 placeholder values
- Document all functions thoroughly  
- Provide clear usage examples
- Consider integration with eye-tracking and physiological data

## 📧 Contact

Alan Sims - alan.sims@griffithuni.edu.au

**Repository**: https://github.com/alan-sims/traffic_psychology

---

*Part of the Traffic Psychology Lab research portfolio investigating motorcycle safety and driver awareness*