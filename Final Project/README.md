# Use of SEA-AD Dataset to Investigate Atherosclerosis Association with Brain Volumetrics

## Setup
- Python requirements: Matplotlib, Numpy, Pandas, Scipy, Seaborn
- Data: The required datafiles can be downloaded from the [SEA-AD website](https://portal.brain-map.org/explore/seattle-alzheimers-disease/seattle-alzheimers-disease-brain-cell-atlas-download?edit&language=en). In particular, the donor metadata file should be saved as `sea-ad_cohort_donor_metadata_072524.xlsx`, the MRI volumetrics file should be saved as `sea-ad_cohort_mri_volumetrics.xlsx`, the Quantitative neuropathology summary data (MTG) file should be saved as `sea-ad_all_mtg_quant_neuropath_bydonorid_081122.csv`, and the Luminex (ABeta and Tau, MTG) file should be saved as `sea-ad_cohort_mtg-tissue_extractions-luminex_data.xlsx`. All these files should be saved to a `data` directory immediately under the `Final Project` directory.

## Data visualization and analysis
- You can run the `scripts/data_exploration.ipynb` notebook to run the visualization and analysis for this project. You may ignore the `scripts/adni_exploration.ipynb`; this was from a side unsuccessful investigation into the ADNI dataset.
