#!/bin/bash

#=======================================================================================================#
#		A Host-based Intrusion Detection System using Bourne Again Shell Script			#
#													#
#				ITEC624 Network Security & Applications	 				#
#													#
#						Assessment 2						#
#													#
#=======================================================================================================#

# Hidden configuration file to store Verification & Output filenames

config_file=".result.txt"
config_file2=".current.txt"

displayUsage() {
	# In the case where some inputs an invalid parameter
	echo "This is an Intrusion Detection System"
	echo "Usage: $0 [options]"
	echo "Options:"
	echo "  -i: Creates files and directories to monitor"
	echo "  -c name1: Creates a verification file called 'name1'"
	echo "  -d: Deletes the non-script related files created"
	echo "  -o name2: Display results, save the outputs to an output file 'name2'
		and verifies the file"
	exit 1
}
createFiles(){
	#Creating files and subdirectories with files
	mkdir "my_dir"
	echo "A file inside a directory" >my_dir/text_1.txt
	echo "My test file 1" >text_2.txt
	mkdir "another_dir"
	echo "Creating another file in another directory" >another_dir/text_4.txt
	echo "Just another file" >text_3.txt
	ln -s text_2.txt text_sym1.txt
	ln -s text_3.txt text_sym2.txt
}

collectData(){
	# Find all the files and directories in the current working directory
	# Then exclude the files with the following name conventions eg README.md
	
	if [ -s "$config_file" ]; then
		verification_file=$(cat "$config_file")
	fi
	if [ -s "$config_file2" ]; then
                current_output=$(cat "$config_file2")
	fi
	echo $(
		find . -type f,l \
			! -name "*.sh" \
			! -name "go.*" \
			! -name "$verification_file" \
			! -name "$current_output" \
			! -name ".result.txt" \
                        ! -name ".current.txt" \
			! -name "diff.txt" \
			! -name "*.md" \
			! -path './.git*'\
	)
}

storeData() {
    # first argument is filename to save results to
    files=$(collectData)
    rm $1 -f
    for i in ${files[@]}; do
	
	if [ -f "$i" ]; then
                file_type="Regular File"
        elif [ -d "$i" ]; then
                file_type="Directory"
        elif [ -L "$i" ]; then
                file_type="Symlink"
        fi
        fileData="$(ls -alF $i) \
		$file_type \
            	$(md5sum $i | awk '{ print $1 }')"
        	# Awk step removes the filename at the end
        $(echo $fileData >>$1)
    done
}

deleteFiles(){
	# Deletes all the files created without warning
	rm -rf another_dir
	rm -rf my_dir
	rm -f text*.txt
	if [ -s $config_file ]; then
		file1=$(cat $config_file)
		rm -f file1
	fi
	if [ -s $config_file2 ]; then
		file2=$(cat $config_file2)
		rm -f file2
	fi
	rm -f .result.txt
	rm -f .current.txt
	rm -f text_2
	rm -f text_3
}

verify(){
	# Compare the VERIICATION_FILE and the OUTPUT_FILE created
	if [ -s "$config_file" ]; then
        	verification_file=$(cat "$config_file")
	fi
	if [ -s "$config_file2" ]; then
        	current_output=$(cat "$config_file2")
	fi

	difference=$(diff -uBr $verification_file $current_output)
	if [ -z "$difference" ]; then
		echo "No intrusions detected."
	else
		echo "There has been an intrusion. Processing the result..."
		echo "$difference" >diff.txt

		declare -A files

		# Skip the first three lines
		while read line; do
			# Check if line is add/ and delete it
			if [[ $line == +-* ]] || [[ $line == --* ]]; then
				# Access the filename
				fileName=$(echo $line | cut -d' ' -f9)
			files[$fileName]+="$line "
			fi
		done < <(sed 1,3d diff.txt)

		# For every key in the associative array..
		for KEY in "${!files[@]}"; do
			printVerificationStatus $KEY ${files[$KEY]}
		done
		rm diff.txt
	fi
}

printVerificationStatus(){
	# Give all the the options for our application
	: ' Arg number: what it is. Add 9 to indexfor next line (if exists)
	2: permissions
	3: number of links
	4: username owner
	5: username group
	6: size
	7: month  modified
	8: date modified
	9: time modified
	10: filename
	11: md5
	'

	echo "Intrusion detected at $1"

	if [[ -z ${12} ]]; then
		if [[ $2 == +-* ]]; then
			echo "New file, created by $4 on $9 at $8 $7"
		elif [[ $2 == --* ]]; then
			echo "File has been deleted"
		fi
	else
		if [[ ${11} != ${21} ]]; then
			echo "MD5 hash change: ${11} -> ${21}"
		fi
		if [[ $4 != ${14} ]] || [[ $5 != ${15} ]]; then
			echo "Ownership change: $4 $5 -> ${14} ${15}"
		fi
		if [[ $9 != ${19} ]] || [[ $8 != ${18} ]] || [[ $7 != ${17} ]]; then
			echo "Timestamp change: $9 $8 $7 -> ${19} ${18} ${17}"
		fi
	fi
	echo "---"
}
# Main Script
# Check if no arguments have been passed and display usage info
if [ $# -eq 0 ]; then
	displayUsage
fi

option1="$1"
case $option1 in
"-i")
	echo "Creating files ..."
	createFiles
	echo "Directories and files created"
	;;
"-c")
	if [ -z "$2" ];then
		displayUsage
	fi
	echo "Scanning the Directory ..."
	echo "$2" > "$config_file"
	storeData "$2"
	echo "File created"
	;;
"-o")
	if [ -z "$2" ];then
                displayUsage
	fi
	echo "Scanning the Directory ..."
	echo "$2" > "$config_file2"
	storeData "$2"
	cat $2
	echo " Checking against verification file ..."
	verify
	storeData "$verification_file"
	;;
"-d")
	echo "Cleaning up the directory..."
	deleteFiles
	echo "Done!"
	;;
# If no option is passed
:)
	displayUsage
	;;
# If an invalid option is passed
*)
	displayUsage
	;;
esac
