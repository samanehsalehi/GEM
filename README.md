# GEM  

GEM (Gene-Environment interaction analysis for Millions of samples) is a software program for large-scale gene-environment interaction testing in samples from unrelated individuals. It enables genome-wide association studies in up to millions of samples while allowing for multiple exposures, control for genotype-covariate interactions, and robust inference.  


<br />
Current version: 1.2  

<br />
Additional documentation:  
https://large-scale-gxe-methods.github.io/GEM-website/index.html  

<br />

## Contents
- [Installation](#installation)
- [Usage](#usage)
- [Contact](#contact)
- [License](#license)

<br />

## Installation  
Library Dependencies:  
* BLAS/LAPACK. For Intel processors, we recommend that the BLAS/LAPACK libraries are linked with optimized math routine libraries such as the Math Kernal Library (MKL) for top performance. The MKL library is set as the default in the makefile. If MKL is not installed, replace ```-lmkl_gf_lp64 -lmkl_sequential -lmkl_core``` in the makefile with the LAPACK/BLAS libraries ```-llapack -lblas```. <br />
* Boost C++ libraries. GEM links the following Boost libraries  ```boost_program_options boost_thread boost_system boost_filesystem``` that will need to be installed prior to executing the makefile.  

<br />

To install GEM, run the following lines of code.
 ```
 git clone https://github.com/large-scale-gxe-methods/GEM
 cd GEM/
 cd src/  
 make  
 ```

<br />
<br />
<br />

## Usage

### Running GEM

1. [Command Line Options](#command-line-options)  
1. [Input Files](#input-files)
1. [Output File Format](#output-file-format)
1. [Examples](#examples)

<br /> 
<br />

Once GEM is installed, the executable ```./GEM``` can be used to run the program.  
For a list of options, use ```./GEM --help```.  

#### Command Line Options

```

General Options:

--help
    Prints the available options of GEM and exits.  
   
   
--version
    Prints the version of GEM and exits.
  
  
  
Input and Output File Options:  

--pheno-file  
     Path to the phenotype file.  

--bgen  
     Path to the BGEN file.  

--sample  
     Path to the sample file.  
     Required when the BGEN file does not contain sample identifiers.  
  
--pfile  
     Path and prefix to the .pgen, .pvar, and .psam files.  
     If this flag is used, then --pgen/--pvar/--psam don�t need to be specified.
  
--pgen  
     Path to the pgen file.  
  
--pvar  
     Path to the pvar file.  
  
--psam  
     Path to the psam file.  
  
--bfile  
     Path and prefix to the .bed, .bim and .fam files.  
     If this flag is used, then --bed/--bim/--fam don�t need to be specified.
  
--bed  
     Path to the bed file.  
  
--bim  
     Path to the bim file.  
  
--fam  
     Path to the fam file.  
  
--out  
     Full path and extension to where GEM output results.  
     Default: gem.out
  
  
  
Phenotype File Options:

--sampleid-name  
     Column name in the phenotype file that contains sample identifiers.  

--pheno-name  
     Column name in the phenotype file that contains the phenotype of interest.  

--exposure-names  
     One or more column names in the phenotype file naming the exposure(s) to be included in interaction tests.  

--int-covar-names  
     Any column names in the phenotype file naming the covariate(s) for which interactions should be included 
     for adjustment (do not include with --exposure-names).  

--covar-names  
     Any column names in the phenotype file naming the covariates for which only main effects should be included
     for adjustment (do not include with --exposure-names or --int-covar-names).  

--pheno-type
     0 indicates a continuous phenotype and 1 indicates a binary phenotype.  

--robust
     0 for model-based standard errors and 1 for robust standard errors.
        Default: 0  

--tol 
     Convergence tolerance for logistic regression.  
        Default: 0.0000001  

--delim  
     Delimiter separating values in the phenotype file. Tab delimiter should be represented as \t and space delimiter as \0.
        Default: , (comma-separated)  

--missing-value  
     Indicates how missing values in the phenotype file are stored.  
        Default: NA
  
--center 
     0 for no centering to be done and 1 to center ALL exposures and covariates.
        Default: 1

--scale
     0 for no scaling to be done and 1 to scale ALL exposures and covariates by the standard deviation.
        Default: 0
   


Filtering Options:  

--maf
     Minimum threshold value [0, 0.5] to exclude variants based on the minor allele frequency.
        Default: 0.001
  
--miss-geno-cutoff
     Maximum threshold value [0, 1.0] to filter variants based on the missing genotype rate.  
        Default: 0.05  
  
--include-snp-file  
     Path to file containing a subset of variants in the specified genotype file to be used for analysis. 
     The first line in this file is the header that specifies which variant identifier in the genotype file  
     is used for ID matching. This must be 'snpid' (PLINK or BGEN) or 'rsid' (BGEN only). There should be one variant 
     identifier per line after the header. Variants not listed in this file will be excluded from analysis.
  
  

Performance Options:  

--threads
     Set number of compute threads.
    	  Default: ceiling(detected threads / 2)  

--stream-snps 
     Number of SNPs to analyze in a batch. Memory consumption will increase for larger values of stream-snps.  
        Default: 1

```

<br /> 

#### Input Files

* ##### Phenotype File
    A file which should contain a sample identifier column and columns for the phenotypes, exposures, and covariates.  
    All binary phenotypes, exposures, and covariates should be coded numerically (e.g., males/females as 0/1)

* ##### Genotype Files
    1. BGEN v1.1, v1.2 or v1.3 genotype files described here [BGEN Format](https://www.well.ox.ac.uk/~gav/bgen_format/spec/latest.html).  
    The BGEN file should only contain bi-allelic unphased/phased genotypes. The second allele in the BGEN file is counted in association testing.   

    2. Plink BED/PGEN genotype files.  
    <ins>BED</ins>  
    .fam files should follow the format described [here](https://www.cog-genomics.org/plink/2.0/formats#fam). The first column must be the FID and the second column must be the IID. GEM will use the IID column for sample identifier matching with the phenotype file.  
    .bim files should contain the chromosome, variant id, cM (optional), base-pair coordinate, ALT allele, and REF allele columns in this order as described [here](https://www.cog-genomics.org/plink/2.0/formats#bim).  
    .bed files must be stored in variant-major form. The ALT allele in the .bim file is counted in association testing.  
    <ins>PGEN</ins>  
    .psam files should follow plink2.0 format described [here](https://www.cog-genomics.org/plink/2.0/formats#psam). If a header line is present, then a column name with #IID (if the first colum is not #FID) or IID (if the first column is #FID) must be present to be used for sample identifier matching with the phenotype file. If no header line is present, then the columns are assumed to be in the .fam file order as described in the link.  
    .pvar files are described [here](https://www.cog-genomics.org/plink/2.0/formats#pvar). If a header line starting with #CHROM is present, then column names POS, ID, REF, and ALT should also be present. If the .pvar file contains no header line, it is assumed that the .pvar file is in .bim file order.  
    .pgen files should only contain bi-allelic genotypes. The second allele is counted in association testing; usually the ALT column in .pvar file.
     
* ##### Sample File
    A .sample file is required when the .bgen file does not contain sample identifiers.  
    .sample files should follow QCTOOL v2 format described here: [.sample example](https://www.well.ox.ac.uk/~gav/qctool_v2/documentation/sample_file_formats.html).  
    The first column must contain the sample identifiers to be matched with phenotype file.  
    
<br /> 

#### Output File Format  

GEM will write results to the output file specified with the --out paramater (or 'gem.out' if no output file is specified).  
Below are details of the column header in the output file.  

```diff
# SNP Info  
SNPID     - The SNP identifier as retrieved from the BGEN file.
RSID      - The reference SNP ID number. (BGEN only)
CHR       - The chromosome of the SNP.
POS       - The physical position of the SNP.
Non_Effect_Allele - The allele not counted for in association testing.  
Effect_Allele - The allele that is counted in association testing.  
N_samples - The number of samples without missing genotypes.
AF        - The allele frequency of the second allele in the BGEN file.


# Betas and Variances
Beta_Marginal      - The coefficient estimate for the marginal genetic effect
Var_Beta_Marginal  - The variance associated with the marginal genetic effect estimate
Beta_Interaction_k - The coefficient estimate for the kth interaction term, 
                     where k = {1..length(--exposure-names)}
Var_Beta_Interaction_k_j - The variance associated with the kth and jth interaction term, 
                           where j = {1..length(--exposure-names)}  

# P-values
P_Value_Marginal    - Marginal genetic effect p-value (GEM does not calculate a genetic main effect that is adjusted for the genetic interaction term(s))
P_Value_Interaction - Interaction effect p-value
P_Value_Joint       - Joint test p-value (K+1 degrees of freedom test of genetic effect)
```

<br />
<br />

### Examples  
<br />

To run GEM using the example data, execute GEM with the following code.
```unix
./GEM --bgen example.bgen --pheno-file example.pheno --sampleid-name sampleid --pheno-name pheno2 --covar-names cov2 cov3 --exposure-names cov1 --pheno-type 1 --robust 1 --missing-value NaN 
```
The results should look like the following output file [example.out](https://github.com/large-scale-gxe-methods/GEM/blob/master/example/my_example.out).  

<br />

GEM allows interaction covariate adjustments by specifying the ```--int-covar-names``` parameter.     
```unix
./GEM --bgen example.bgen --pheno-file example.pheno --sampleid-name sampleid --pheno-name pheno2 --covar-names cov2 --exposure-names cov1 --int-covar-names cov3 --pheno-type 1 --robust 1 --missing-value NaN 
```

<br />
<br />


## Contact 
For comments, suggestions, bug reports and questions, please contact Han Chen (Han.Chen.2@uth.tmc.edu), Alisa Manning (AKMANNING@mgh.harvard.edu), Kenny Westerman (KEWESTERMAN@mgh.harvard.edu), or Duy Pham (Duy.T.Pham@uth.tmc.edu). For bug reports, please include an example to reproduce the problem without having to access your confidential data.

<br />
<br />

## License 

 ```
 GEM : Gene-Environment interaction analysis for Millions of samples
 Copyright (C) 2018-2021  Liang Hong, Han Chen, Duy Pham
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ```
