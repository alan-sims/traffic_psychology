# Close Following Rural Being Tailgated

## Scenario Overview

In this scenario, the participant drives along a rural road with one lane in each direction, separated by a double white line (no overtaking allowed). The road has a baseline speed limit of 100km/h, but drops to 60km/h when passing through a small township in the middle of the scenario.

Throughout the drive, a white BMW follows the participant's vehicle. The following behavior changes at a critical trigger point approximately halfway through the scenario.

## Following Vehicle Behavior

The white BMW behind the participant follows with varying distances:
- **First half of drive**: 2.5 second following gap
- **After trigger point**: 0.5 second following gap (much closer, more aggressive tailgating)

We will inspect the data to see how participants alter their driving behavior when the following distance becomes uncomfortably close.

## Drive Sections

| Section | Description |
|---------|-------------|
| 0 | Warm-up period (0-200m) - allows participants to reach comfortable speed |
| 1 | Rural road 100km/h (initial phase with normal following) |
| 2 | Township section with 60km/h speed limit |
| 3 | Rural road 100km/h (return to highway speed, normal following continues) |
| 4 | Rural road 100km/h (BMW changes to aggressive 0.5s following distance) |

## Export Channel Outcome Variables

| Variable | Description |
|----------|-------------|
| `time` | Time elapsed in the scenario (0.05 second intervals) |
| `[03 (Driver/Driver Speed)].ExportChannel-val` | Driver speed in km/h |
| `[06 (Driver/Driver Lane Lateral Shift)].ExportChannel-val` | Lateral shift in the lane |
| `[09 (Driver/Lane Number)].ExportChannel-val` | The lane number that the participant's car is in |
| `[10 (Driver/Braking)].ExportChannel-val` | The pressure applied to the brake pedal |
| `[17 (Driver/Drive Section)].ExportChannel-val` | The section of the drive |
| `[00].VehicleUpdate-roadInfo-roadAbscissa.0` | The distance (in metres) that the person is along that section of road |
| `[00].VehicleUpdate-roadInfo-laneId.0` | The ID of the lane that the participant is in |

## Key Research Questions

- How does driving behavior change between normal following (2.5s) and aggressive tailgating (0.5s)?
- Do participants adjust speed, lateral position, or braking patterns when being tailgated closely?
- How does the rural road environment affect responses to tailgating compared to highway scenarios?
- Are there differences in behavior between the township (60km/h) and rural (100km/h) sections?

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
Close_Following_Rural_Being_Tailgaited-DD_MM_YYYY-HHhMMmSSs_PPPP.csv
```

Where:
- `DD_MM_YYYY` = Date (e.g., 02_07_2025)
- `HHhMMmSSs` = Time (e.g., 13h56m57s) 
- `PPPP` = 4-digit participant ID (e.g., 1234)

**Example:** `Close_Following_Rural_Being_Tailgaited-02_07_2025-13h56m57s_1234.csv`

### 3. Organize Your Data
Place your CSV files in the appropriate folder:
```
data/raw/rural/being_tailgated/
├── Close_Following_Rural_Being_Tailgaited-02_07_2025-13h56m57s_1234.csv
├── Close_Following_Rural_Being_Tailgaited-03_07_2025-09h15m22s_1235.csv
└── Close_Following_Rural_Being_Tailgaited-04_07_2025-14h33m08s_1236.csv
```

### 4. Run the Analysis

#### For a Single File:
```r
source("R/rural/being_tailgated/rural_being_tailgated.R")

file_path <- "data/raw/rural/being_tailgated/Close_Following_Rural_Being_Tailgaited-02_07_2025-13h56m57s_1234.csv"
results <- analyze_rural_tailgated(file_path)
```

#### For Multiple Files (Batch Processing):
```r
source("R/rural/being_tailgated/rural_being_tailgated.R")

# Process all files in the folder
summary_data <- process_rural_tailgated_batch("data/raw/rural/being_tailgated/")
```

This will:
- Process all CSV files in the folder
- Extract participant ID, date, and time from filenames
- Calculate metrics for each participant across all 5 sections
- Create a summary CSV file at `output/rural_being_tailgated_summary.csv`

## Output

### Single File Analysis
The console will display:
- Duration and observations for each section
- Average speed by drive section (0-4)
- Standard Deviation of Lateral Position (SDLP) by section
- Braking events and lane changes by section
- Crash detection results

### Batch Processing Summary CSV
The summary file contains these columns:
- `participant_id` - 4-digit participant number
- `date` - Date in DD/MM/YYYY format
- `time` - Time in HH:MM:SS format
- `filename` - Original filename

**Section-wise metrics (for sections 0-4):**
- `avg_speed_section_X` - Average speed (km/h) for each section
- `sdlp_section_X` - Standard Deviation of Lateral Position for each section
- `total_braking_events_section_X` - Number of brake applications in each section
- `potential_crashes_section_X` - Detected potential crash events in each section

## Data Requirements

Your CSV files should contain tab-separated data with these columns:
- Time elapsed (0.05 second intervals)
- Driver speed (km/h)
- Lane lateral shift
- Lane number
- Braking pressure
- Drive section number (0-4)
- Road distance
- Lane ID

## Interpretation Guide

### Expected Behavioral Changes

**Section 0 (Warm-up)**: Expect variable speeds as participants adjust to the scenario

**Sections 1-3 (Normal Following)**: 
- Steady speeds appropriate to speed limits (100km/h rural, 60km/h township)
- Low SDLP indicating stable lane position
- Minimal braking events

**Section 4 (Aggressive Tailgating)**: Watch for:
- Speed increases (trying to get away from tailgater)
- Increased SDLP (lateral movement/anxiety)
- More frequent braking events
- Potential lane changes or erratic behavior

### Key Comparisons

**Rural vs Highway**: Compare section 4 results with highway being tailgated data to see if road type affects tailgating responses

**Speed Limit Changes**: Compare sections 1-2 transition to see how speed limit changes interact with tailgating stress

**Individual Differences**: Look for participants who show strong vs. minimal responses to aggressive tailgating

## Troubleshooting

**File not found errors:**
- Check that your file path is correct
- Ensure you're in the project directory (open the .Rproj file)

**Parsing errors:**
- Verify your CSV file follows the expected tab-separated format
- Check that the filename follows the naming convention

**No files found:**
- Ensure CSV files are in the correct folder (`data/raw/rural/being_tailgated/`)
- Check that filenames contain "Rural_Being_Tailgaited" and end with `.csv`

**Missing sections in output:**
- Some participants may not complete all sections
- Check the raw data to confirm section numbers are present

## Project Structure
```
close_following/
├── R/rural/being_tailgated/
│   └── rural_being_tailgated.R       # Analysis functions
├── data/raw/rural/being_tailgated/   # Place your CSV files here
├── output/                           # Summary files created here
├── docs/                             # Documentation
├── close-following.Rproj             # R project file
└── README.md                         # Project overview
```

## Next Steps
This framework can be extended to analyze the other driving scenarios:
- Highway being tailgated ✓
- Highway tailgating ✓
- Rural being tailgated ✓
- Rural tailgating (coming soon)

Contact Alan Sims - alan.sims@griffithuni.edu.au for questions or to contribute.