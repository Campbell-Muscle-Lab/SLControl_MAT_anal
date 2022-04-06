---
title: Analyze folders
has_children: false
nav_order: 3
---

# Analyze folders

The function `analyze_folders()` in `<repo>/code` is an entry point function that coordinates the analysis of SLControl folders contained in a nested structure.

## Inputs

| Input | Description |
|---|---|
| top_data_dir | the top folder in the directory structure containing the SLControl files. The code will search recursively through the structure |
| top_output_dir | the top folder in a structure to hold the output data. The code will duplicate the structure of the SLControl folders, and store analysis images in the appropriate locations. A summary file will be created in the top folder |
|no_of_nested_levels | The number of factors in your experimental design |


### Nested levels

As an example, if:
+ SLControl files are located in `c:/temp/a/b/c/d`
+ `no_of_nested_levels` is 2

The summary data will note:
+ `factor_1` is `a`
+ `factor_2` is `b`
+ `prep` is `c`

See [organization](../organization/organization.html) for more information.

## Outputs

+ `analysis.xlsx` is written to `top_data_dir` and contains two sheets
  + `prep_data` - information about the preparation, including pCa50, n_H, and prep dimensions
  + `trace_data` - information about individual SLControl records, including force, k_tr

+ `superposed.png` is written to each folder containing SLControl files
  + shows all SLControl records in the folder superposed
  + useful for trouble-shooting

+ `pCa.png` is written to each folder containing SLcontrol files
  + shows final force record in each SLControl file plotted against pCa
  + useful for trouble-shooting

+ `k_tr_xxx.png`
  + shows k_tr fits for each SLControl record
