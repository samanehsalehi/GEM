task run_tests {

	File genofile
	File? samplefile
	File phenofile
	String sample_id_header
	String outcome
	Boolean binary_outcome
	String covar_headers
	String? int_covar_num = 1
	String? delimiter = ","
	String? missing = "NaN"
	Boolean robust
	String? stream_snps = 20
	String? tol = "0.000001"
	String out_name
	String? memory = 10
	String? disk = 20

	String pheno = if binary_outcome then "1" else "0"
	String robust01 = if robust then "1" else "0"

	command {
		echo -e "SAMPLE_ID_HEADER\n${sample_id_header}\n"\
			"PHENOTYPE\n${pheno}\n"\
			"PHENO_HEADER\n${outcome}\n"\
			"COVARIATES_HEADERS\n${covar_headers}\n"\
			"MISSING\n${missing}\n"\
			"ROBUST\n${robust01}\n"\
			"STREAM_SNPS\n${stream_snps}\n"\
			"NUM_OF_INTER_COVARIATE\n${int_covar_num}\n"\
			"LOGISTIC_CONVERG_TOL\n${tol}\n"\
			"DELIMINATOR\n${delimiter}\n"\
			"GENO_FILE_PATH\n${genofile}\n"\
			"PHENO_FILE_PATH\n${phenofile}\n"\
			"SAMPLE_FILE_PATH\n${samplefile}\n"\
			"OUTPUT_PATH\n${out_name}_res"\
			> GEM_Input.param

		/GEM/GEM GEM_Input.param
	}

	runtime {
		docker: "quay.io/large-scale-gxe-methods/gem-workflow"
		memory: "${memory} GB"
		disks: "local-disk ${disk} HDD"
	}

	output {
		File out = "${out_name}_res"
		File param_file = "GEM_Input.param"
	}
}

workflow run_GEM {

	Array[File] genofiles
	File? samplefile
	File phenofile
	String? sample_id_header
	String outcome
	Boolean binary_outcome
	String covar_headers
	String int_covar_num
	String? delimiter
	String? missing
	Boolean robust
	String? stream_snps
	String? tol
	Array[String] out_names
	String? memory
	String? disk

	scatter (i in range(length(genofiles))) {
		call run_tests {
			input:
				genofile = genofiles[i],
				samplefile = samplefile,
				phenofile = phenofile,
				sample_id_header = sample_id_header,
				outcome = outcome,
				binary_outcome = binary_outcome,
				covar_headers = covar_headers,
				int_covar_num = int_covar_num,
				delimiter = delimiter,
				missing = missing,
				robust = robust,
				stream_snps = stream_snps,
				tol = tol,
				out_name = out_names[i],
				memory = memory,
				disk = disk
		}
	}

	parameter_meta {
		genofiles: "Array of genotype filepaths in .bgen format."
		samplefile: "Optional .sample file accompanying the .bgen file. Required for proper function if .bgen does not store sample identifiers."
		phenofile: "Phenotype filepath."	
		sample_id_header: "Column header name of sample ID in phenotype file."
		outcome: "Column header name of phenotype data in phenotype file."
                binary_outcome: "Boolean: is the outcome binary? Otherwise, quantitative is assumed."
		covar_headers: "Column header names of the selected covariates in the pheno data file."
		int_covar_num: "Indexes of the covariates for which interactions with genotype should be included ('1' means use the first covariate, '2 3' means use the second and third covariates, etc.)."
		delimiter: "Delimiter used in the phenotype file."
		missing: "Missing value key of phenotype file."
                robust: "Boolean: should robust (a.k.a. sandwich/Huber-White) standard errors be used?"
		stream_snps: "SNP numbers for each GWAS analysis."
		tol: "Convergence tolerance for logistic regression."
		out_names: "Array of names to distinguish output files (e.g. chromosome numbers)."
		memory: "Requested memory (in GB)."
		disk: "Requested disk space (in GB)."
	}

        meta {
                author: "Kenny Westerman"
                email: "kewesterman@mgh.harvard.edu"
                description: "Run interaction tests using GEM and return a table of summary statistics for 1-DF and 2-DF tests."
        }
}
