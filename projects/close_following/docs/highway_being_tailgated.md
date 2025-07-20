# Close Following - Highway - Being Tailgated

## Scenario Overview

In this scenario, the participant drives along a highway with 2 lanes heading in each direction, separated by a guardrail. The speed limit for the highway is signposted as 100km/h. Along the side of the road there are 4 hazards that typically cause drivers to adjust their speed and slow down on the highway.

## Hazards

These hazards are (in order that they appear in the scenario):

1. **Car breakdown** - A car stopped on the shoulder
2. **Police presence** - A police car sitting on the side of the road, just after an exit ramp
3. **Roadworks** - A small roadworks section with an 80km/h speed limit
4. **Speed detection** - A white van similar to those used as police radar speed detection vehicles
> [!NOTE]
> Would be good to add pictures to these
## Traffic Behavior

The other cars in the scenario are programmed to drop their speed during those hazards:
- For the 1st, 2nd, and 4th hazard: speed drops to **90km/h**
- For the 3rd hazard (roadworks): speed drops to **80km/h**

## Following Vehicle Behavior

Throughout the scenario there is a truck following the participant's car with varying following distances:
- **First half of drive**: 2 second gap
- **After section 6 trigger point**: 0.5 second gap (much closer following)

We will inspect the data to see if participants alter their driving behaviour around the hazards and/or when the truck following distance changes.

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

## Export Channel Outcome Variables

| Variable | Description |
|----------|-------------|
| `time` | Time elapsed in the scenario (0.05 second intervals) |
| `[00 (AcquisitionMapping/ACCELERATOR)].ExportChannel-val` | Pressure on the accelerator |
| `[03 (Driver/Driver Speed)].ExportChannel-val` | Driver speed in km/h |
| `[06 (Driver/Driver Lane Lateral Shift)].ExportChannel-val` | Lateral shift in the lane |
| `[09 (Driver/Lane Number)].ExportChannel-val` | The lane number that the participant's car is in |
| `[10 (Driver/Braking)].ExportChannel-val` | The pressure applied to the brake pedal |
| `[17 (Driver/Drive Section)].ExportChannel-val` | The section of the drive |
| `[00].VehicleUpdate-roadInfo-roadAbscissa.0` | The distance (in metres) that the person is along that section of road |
| `[00].VehicleUpdate-roadInfo-laneId.0` | The ID of the lane that the participant is in |


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
git clone https://github.com/alan-sims/traffic_psychology.git
cd close_following
```

#### Option B: Download ZIP (Alternative)
If you don't have Git:
1. Go to the GitHub repository page: github.com/alan-sims/traffic_psychology/
2. Click the green "Code" button
3. Select "Download ZIP"
4. Extract the ZIP file to your desired location
5. Rename the folder to `traffic_psychology` if needed

#### Opening the Project
1. Open RStudio or Positron IDE
2. Go to File → Open Project (or File → Open Project in New Session)
3. Navigate to the `traffic_psychology` folder
4. Click on `traffic_psychology.Rproj` and select "Open"

#### Install Required Packages
Once the project is open, run this in the R console:
```r
install.packages(c("tidyverse", "readr"))
```

### 2. Data File Naming Convention
Your CSV files must follow this naming pattern:
```
Close_Following_Highway_Being_Tailgaited-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```

Where:
- `DD_MM_YYYY` = Date (e.g., 25_06_2025)
- `HHhMMmSSs` = Time (e.g., 15h07m17s) 
- `PPPP` = 4-digit participant ID (e.g., 1234)

**Example:** `Close_Following_Highway_Being_Tailgaited-25_06_2025-15h07m17s_1234.csv`

### 3. Organize Your Data
Place your CSV files in the appropriate folder:
```
data/raw/highway/being_tailgated/
├── Close_Following_Highway_Being_Tailgaited-25_06_2025-15h07m17s_1234.csv
├── Close_Following_Highway_Being_Tailgaited-26_06_2025-10h15m30s_1235.csv
└── Close_Following_Highway_Being_Tailgaited-27_06_2025-14h22m45s_1236.csv
```

### 4. Run the Analysis

#### For a Single File:
```r
source("R/highway_being_tailgated.R")

file_path <- "data/raw/highway/being_tailgated/Close_Following_Highway_Being_Tailgaited-25_06_2025-15h07m17s_1234.csv"
results <- analyze_highway_tailgated(file_path)
```

#### For Multiple Files (Batch Processing):
```r
source("R/highway_being_tailgated.R")

# Process all files in the folder
summary_data <- process_highway_tailgated_batch("data/raw/highway/being_tailgated/")
```

This will:
- Process all CSV files in the folder
- Extract participant ID, date, and time from filenames
- Calculate metrics for each participant
- Create a summary CSV file at `output/highway_tailgated_summary.csv`

## Output

### Single File Analysis
The console will display:
- Average speed by drive section (1-10)
- Average lateral position by drive section
- Crash detection results

### Batch Processing Summary CSV
The summary file contains these columns:
- `participant_id` - 4-digit participant number
- `date` - Date in YYYY-MM-DD format
- `time` - Time in HH:MM:SS format
- `crashed` - TRUE/FALSE if crash detected
- `crash_count` - Number of crash events
- `avg_speed_section_1` to `avg_speed_section_10` - Average speeds (km/h) for each section
- `sdlp_section_1` to `sdlp_section_10` - Standard Deviation of Lateral Position for each section

## Data Requirements

Your CSV files should contain tab-separated data with these columns:
- Time elapsed (0.05 second intervals)
- Accelerator pressure
- Driver speed (km/h)
- Lane lateral shift
- Lane number
- Braking pressure
- Drive section number
- Road distance
- Lane ID

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
