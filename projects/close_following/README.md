# Close Following Behavior Analysis

Comprehensive analysis of close following behavior across four driving scenarios comparing highway vs rural environments and being tailgated vs tailgating roles.

## 📋 Project Overview

This project examines how drivers respond to close following situations across different road types and following roles. We analyze high-frequency driving simulation data to understand the behavioral patterns, safety implications, and individual differences in tailgating scenarios.

## 🛣️ Scenarios Analyzed

| Scenario | Environment | Role | Key Features |
|----------|-------------|------|-------------|
| [Highway - Being Tailgated](docs/highway_being_tailgated.md) | Highway (100km/h) | Passive | Truck follows at 2s → 0.5s after section 6 |
| [Highway - Tailgating](docs/highway_tailgating.md) | Highway (100km/h) | Active | Following slow cars (90km/h) in left lane |
| [Rural - Being Tailgated](docs/rural_being_tailgated.md) | Rural (100/60km/h) | Passive | BMW follows at 2.5s → 0.5s, no overtaking |
| [Rural - Tailgating](docs/rural_tailgating.md) | Rural (100/60km/h) | Active | Following slow cars, no overtaking allowed |

## 🔬 Research Questions

1. **Road Environment Effects**: How does road type (highway vs rural) affect close following behavior?
2. **Following Role Effects**: How does following role (being tailgated vs tailgating) change driver responses?
3. **Interaction Effects**: What are the interaction effects between road type and following role?
4. **Safety Assessment**: Which scenarios present the highest stress and safety risks?

## 📊 Data Structure

- **Sampling Rate**: 0.05-second intervals (20 Hz)
- **File Format**: Tab-separated CSV with complex column names
- **Participants**: Multiple drivers across all four scenarios
- **Metrics**: Speed, lateral position, braking, headway distance/time

## 🚀 Quick Start

### Prerequisites
- R (4.0+) with tidyverse
- RStudio or Positron IDE

### Running Analysis

```r
# Open the R project
# File → Open Project → close_following.Rproj

# For single file analysis
source("R/highway/being_tailgated/highway_being_tailgated.R")
result <- analyze_highway_tailgated("data/raw/highway/being_tailgated/file.csv")

# For batch processing
summary <- process_highway_tailgated_batch("data/raw/highway/being_tailgated/")
```

### Expected Data Format
```
Close_Following_[Scenario]_[DD_MM_YYYY]_[HHhMMmSSs]_[ParticipantID].csv
```

## 📁 Project Structure

```
close_following/
├── R/                           # Analysis functions
│   ├── highway/
│   │   ├── being_tailgated/     # Highway passive scenario
│   │   └── tailgating/          # Highway active scenario
│   └── rural/
│       ├── being_tailgated/     # Rural passive scenario  
│       └── tailgating/          # Rural active scenario
├── data/raw/                    # Raw CSV files (excluded from git)
│   ├── highway/
│   └── rural/
├── output/                      # Summary CSV files
├── docs/                        # Scenario documentation
├── close_following.Rproj       # R project file
└── README.md                    # This file
```

## 📈 Key Metrics

### Universal Metrics (All Scenarios)
- **Speed**: Average, SD, min, max by section
- **SDLP**: Standard Deviation of Lateral Position
- **Braking**: Event counts and pressure
- **Safety**: Crash detection heuristics

### Tailgating-Specific Metrics
- **Headway Distance**: Following distance in meters
- **Time Headway**: Following time in seconds
- **Close Following Events**: Count of headway < 2s
- **Very Close Following**: Count of headway < 1s

## 🎯 Expected Outcomes

### Behavioral Patterns
- Increased lateral movement when being tailgated
- Closer following in rural vs highway scenarios
- Speed adjustments during aggressive tailgating
- Individual differences in tailgating tolerance

### Safety Implications
- Critical headway thresholds for crash risk
- Environmental factors affecting following behavior
- Intervention points for safety systems

## 📄 Documentation

Each scenario has detailed documentation:
- Setup and installation guides
- Data requirements and naming conventions
- Analysis examples and interpretation
- Troubleshooting common issues

## ✅ Current Status

**Complete**: All four scenarios implemented and tested
- ✅ Highway being tailgated analysis
- ✅ Highway tailgating analysis  
- ✅ Rural being tailgated analysis
- ✅ Rural tailgating analysis
- ✅ Batch processing capabilities
- ✅ Comprehensive documentation

## 🤝 Contributing

This project follows lab coding standards:
- Use tidyverse conventions
- Document all functions thoroughly
- Include error handling and validation
- Provide usage examples

## 📧 Contact

Alan Sims - alan.sims@griffithuni.edu.au

**Repository**: https://github.com/alan-sims/traffic_psychology

---

*Part of the Traffic Psychology Lab research portfolio*