# Close Following - Highway - Tailgating

## Scenario Overview

In this scenario, the participant drives along a highway with 2 lanes heading in each direction, separated by a guardrail. The speed limit for the highway is signposted as 100km/h. Along the side of the road there are 4 hazards that typically cause drivers to adjust their speed and slow down on the highway.

The participant is the one doing the tailgating - following other vehicles closely, particularly slow cars that sit in the left lane at 90km/h. We are interested in seeing the close following behavior of the participant in regards to these slower cars.

## Hazards

These hazards are (in order that they appear in the scenario):

1. **Car breakdown** - A car stopped on the shoulder
2. **Police presence** - A police car sitting on the side of the road, just after an exit ramp  
3. **Roadworks** - A small roadworks section with an 80km/h speed limit
4. **Speed detection** - A white van similar to those used as police radar speed detection vehicles

> [!NOTE]
> Would be good to add pictures of these

## Traffic Behavior

The other cars in the scenario are programmed to drop their speed during those hazards:
- For the 1st, 2nd, and 4th hazard: speed drops to **90km/h**
- For the 3rd hazard (roadworks): speed drops to **80km/h**

There are a number of slow cars (constantly 90km/h) that sit in the left lane, creating opportunities for close following behavior.

## Drive Sections

| Section | Description |
|---------|-------------|
| 1 | 200m after starting until breakdown start |
| 2 | Breakdown start until breakdown end |
| 3 | Breakdown end until police car start |
| 4 | Police car start until police car end |
| 5 | Police car end until section 6 trigger point |
| 6 | Section 6 trigger until roadworks start |
| 7 | Roadworks start until roadworks end |
| 8 | Roadworks end until speed camera zone starts |
| 9 | Speed camera zone starts until speed camera zone ends |
| 10 | Speed camera zone ends until end of scenario |

> [!NOTE]
> The section 6 trigger is the same point where the truck would start to follow closer in the highway_being_tailgated scenario. It is left in here for continuity.

## Export Channel Outcome Variables

| Variable | Description |
|----------|-------------|
| `time` | Time elapsed in the scenario (0.05 second intervals) |
| `[03 (Driver/Driver Speed)].ExportChannel-val` | Driver speed in km/h |
| `[05 (Driver/Headway Distance)].ExportChannel-val` | Distance (in metres) behind the car in front |
| `[06 (Driver/Driver Lane Lateral Shift)].ExportChannel-val` | Lateral shift in the lane |
| `[10 (Driver/Braking)].ExportChannel-val` | The pressure applied to the brake pedal |
| `[12 (Driver/Time Headway)].ExportChannel-val` | The time in seconds that participant is from the car in front |
| `[13 (Driver/Vehicle In Front ID)].ExportChannel-val` | The ID number of the car in front of the participant |
| `[17 (Driver/Drive Section)].ExportChannel-val` | The section of the drive |
| `[00].VehicleUpdate-roadInfo-roadAbscissa.0` | The distance (in metres) that the person is along that section of road |
| `[00].VehicleUpdate-roadInfo-laneId.0` | The ID of the lane that the participant is in |

## Key Tailgating Metrics

This scenario focuses on measuring:
- **Headway Distance**: How close the participant follows other vehicles
- **Time Headway**: Following time in seconds (critical safety measure)
- **Brake Events**: Frequency of braking due to close following
- **Lane Changes**: Lateral movement indicating overtaking attempts
- **Speed Variations**: How speed changes during close following situations

## Quick Start Guide

### 1. Setup

#### Prerequisites
- **R** (version 4.0 or later): Download from [https://cran.r-project.org/](https://cran.r-project.org/)
- **RStudio** or **Positron IDE**: 
  - RStudio: [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)
  - Positron: [https://github.com/posit-dev/positron](https://github.com/posit-dev/positron)
- **Git** (optional but recommended): [https://git-scm.com/downloads](https://git-scm.com/downloads)

#### Option A: Using Git (Recommended)
If you have Git installed:
1. Open Terminal (Mac/Linux) or Command Prompt (Windows)
2. Navigate to where you want to save the project
3. Run these commands:
```bash
git clone https://github.com/alan-sims/close_following.git
cd close_following
```

#### Option B: Download ZIP (Alternative)
If you don't have Git:
1. Go to the GitHub repository page: [your-github-repo-url]
2. Click the green "Code" button
3. Select "Download ZIP"
4. Extract the ZIP file to your desired location
5. Rename the folder to `close_following` if needed

#### Opening the Project
1. Open RStudio or Positron IDE
2. Go to File → Open Project (or File → Open Project in New Session)
3. Navigate to the `close_following` folder
4. Click on `close-following.Rproj` and select "Open"

#### Install Required Packages
Once the project is open, run this in the R console:
```r
install.packages(c("tidyverse", "readr"))
```

### 2. Data File Naming Convention
Your CSV files must follow this naming pattern:
```
Close_Following_Highway_Tailgaiting-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```

Where:
- `DD_MM_YYYY` = Date (e.g., 25_06_2025)
- `HHhMMmSSs` = Time (e.g., 14h50m03s) 
- `PPPP` = 4-digit participant ID (e.g., 1234)

**Example:** `Close_Following_Highway_Tailgaiting-25_06_2025-14h50m03s_1234.csv`

### 3. Organize Your Data
Place your CSV files in the appropriate folder:
```
data/raw/highway/tailgating/
├── Close_Following_Highway_Tailgaiting-25_06_2025-14h50m03s_1234.csv
├── Close_Following_Highway_Tailgaiting-26_06_2025-11h22m15s_1235.csv
└── Close_Following_Highway_Tailgaiting-27_06_2025-16h35m42s_1236.csv
```

### 4. Run the Analysis

#### For a Single File:
```r
source("R/highway/tailgating/highway_tailgating.R")

file_path <- "data/raw/highway/tailgating/Close_Following_Highway_Tailgaiting-25_06_2025-14h50m03s_1234.csv"
results <- analyze_highway_tailgating(file_path)
```

#### For Multiple Files (Batch Processing):
```r
source("R/highway/tailgating/highway_tailgating.R")

# Process all files in the folder
summary_data <- process_highway_tailgating_batch("data/raw/highway/tailgating/")
```

This will:
- Process all CSV files in the folder
- Extract participant ID, date, and time from filenames
- Calculate tailgating metrics for each participant
- Create a summary CSV file at `output/highway_tailgating_summary.csv`

## Output

### Single File Analysis
The console will display:
- Average speed by drive section (1-10)
- Standard Deviation of Lateral Position (SDLP) by section
- Average headway distance and time by section
- Minimum headway values (indicating closest following)
- Brake event counts by section
- Safety metrics and crash detection

### Batch Processing Summary CSV
The summary file contains these columns:
- `participant_id` - 4-digit participant number
- `date` - Date in DD_MM_YYYY format
- `time` - Time in HHhMMmSSs format
- `crash_detected` - TRUE/FALSE if crash detected
- `min_headway_overall` - Closest following distance across entire drive
- `max_braking_overall` - Maximum braking pressure applied

**Section-wise metrics (for sections 1-10):**
- `section_X_avg_speed` - Average speed (km/h)
- `section_X_sdlp` - Standard Deviation of Lateral Position
- `section_X_avg_headway_distance` - Average following distance (m)
- `section_X_avg_time_headway` - Average following time (s)
- `section_X_min_headway_distance` - Closest following distance (m)
- `section_X_min_time_headway` - Shortest following time (s)
- `section_X_max_braking` - Maximum braking pressure
- `section_X_total_brake_events` - Number of brake applications

## Data Requirements

Your CSV files should contain tab-separated data with these columns:
- Time elapsed (0.05 second intervals)
- Driver speed (km/h)
- Headway distance (metres)
- Lane lateral shift
- Braking pressure
- Time headway (seconds)
- Vehicle in front ID
- Drive section number
- Road distance
- Lane ID

## Interpretation Guide

### Normal vs. Aggressive Tailgating Indicators

**Normal Following:**
- Time headway > 2 seconds
- Headway distance > 50 meters at highway speeds
- Low SDLP (< 0.2) indicating stable lane position
- Infrequent brake events

**Aggressive Tailgating:**
- Time headway < 1 second
- Headway distance < 30 meters at highway speeds
- High SDLP (> 0.3) indicating frequent lane changes
- Frequent brake events (> 10 per section)

### Section-Specific Expectations

**Sections 2, 4, 7, 9** (Hazard zones): Expect closer following as traffic slows
**Section 6**: Critical transition point - watch for behavior changes
**Sections 1, 3, 5, 8, 10**: Baseline driving behavior

## Troubleshooting

**File not found errors:**
- Check that your file path is correct
- Ensure you're in the project directory (open the .Rproj file)

**Parsing errors:**
- Verify your CSV file follows the expected tab-separated format
- Check that the filename follows the naming convention

**No files found:**
- Ensure CSV files are in the correct folder
- Check that filenames end with `.csv`

**"No valid data" in safety metrics:**
- This indicates missing headway or braking data
- Check your data source and export settings

## Project Structure
```
close_following/
├── R/
│   ├── highway/
│   │   ├── being_tailgated/
│   │   │   └── highway_being_tailgated.R
│   │   └── tailgating/
│   │       └── highway_tailgating.R
│   └── rural/
│       ├── being_tailgated/
│       │   └── rural_being_tailgated.R
│       └── tailgating/
│           └── rural_tailgating.R
├── data/raw/
│   ├── highway/
│   │   ├── being_tailgated/    # Highway being tailgated CSV files
│   │   └── tailgating/         # Highway tailgating CSV files
│   └── rural/
│       ├── being_tailgated/    # Rural being tailgated CSV files
│       └── tailgating/         # Rural tailgating CSV files
├── output/                     # Summary CSV files
├── docs/                       # Documentation for each scenario
├── scripts/                    # Additional analysis scripts
├── close-following.Rproj      # R project file
├── .gitignore                 # Git ignore file
└── README.md                  # Project overview
```



Contact [Alan Sims](mailto:alan.sims@griffithuni.edu.au) for questions or to contribute.
