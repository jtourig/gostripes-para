# build a gostripes sample sheet from a list or pattern/glob of fastq files

# Example Usage:
# $source path/to/gostripes-para/lib/build_sample_sheet.bash 
# $build_sample_sheet your/fq/dir your/output/dir/gostripes_samples.txt K562

 build_sample_sheet() {
 	local fastq_dir="$1" out_path="${2:-./gostripes_sample_sheet.txt}" file_IDer="$3"
 	# arg checking
 	[[ -d $fastq_dir ]] || { echo -e "  ERROR: fastq dir does not exist\n  Exiting..."; exit 1; }
 	local R1_IDer='_R1_001.fastq' R2_IDer='_R2_001.fastq'
 	local R1s R1_path R2_path R1_fname sample_name name_trimmer="${R1_IDer/#/_S[0-9]*}"
	>&2 echo -e "  building sample sheet from fastq dir:\n    $fastq_dir \n" \
		" with file pattern: *${file_IDer}*${R1_IDer}\n" \
		" trimming $name_trimmer from R1 to make sample names"
	# print some useful header info first - will also overwite existing file
	echo '# gostripes-para samples sheet auto-generated from:' > "$out_path"
	echo "#   ${fastq_dir}/*${file_IDer}*${R1_IDer}" >> "$out_path"
	printf -- '%s\t%s\t%s\t%s\n' '#sample_name' 'R1' 'R2' >> "$out_path"
	# glob the R1 fastqs
	R1s=( "${fastq_dir}"/*${file_IDer}*${R1_IDer} )
	# check that the glob worked
	[[ ! $R1s == *[\*\?\[\]]* ]] \
			|| { >&2 echo -e '\n  Glob failed - check pattern/path \n  Exiting...\n'; exit 1; }
	# give feedback on glob results
	>&2 echo '  R1s found:'
	>&2 printf -- '    %s\n' "${R1s[@]}"
	# fill out table
	for R1_path in "${R1s[@]}"; do
		R2_path="${R1_path/$R1_IDer/$R2_IDer}"
		[[ -f $R2_path ]] \
			|| { >&2 echo -e "  ERROR: R2 not found:\n    $R2 \n  check patterns/IDers\n  Exiting..."; exit 1; }
		R1_fname="${R1_path##*/}"
		sample_name="${R1_fname%$name_trimmer}"
		printf -- '%s\t%s\t%s\n' "$sample_name" "$R1_path" "$R2_path" >> "$out_path"
	done
	>&2 echo -e "  sample sheet written to:\n    $out_path"
}

#NOTE if your R1/R2 identifer substrings are different, set those local vars to what works
#  with your seq file naming scheme.  Same goes for the substring to trim from R1 seq files
#  to name samples.
#NOTE if you want to specify an additional file_IDer as the third arg, you must also specify
#  the output path in the second arg (this can just be the empty string '' if you want to
#  use default naming )

#TODO: consider enabling bash globfail option instead of trying to check manually
