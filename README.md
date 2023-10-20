Introduction
Monitoring files in network security is critical to detect any malicious attacks on the file system and take the necessary actions. “In UNIX shells, the Bourne shell (sh) stands out as the original shell developed by Stephen Bourne in 1977, and it is widely recognizable by the distinctive '$' sign (Kidwai et al., 2021)." This Bourne Again shell script is designed to serve as a simple Host-based Intrusion Detection System or HIDS, an essential part of network security. 
"Intrusion detection systems (IDS) serve as a critical component in network security. They monitor and collect data from the system being monitored, check for intrusions, and give responses when evidence of an intrusion is detected (Ou, Lin, & Zhang, 2010)."
The primary purpose of the script is to monitor all the regular files, sub-directories, and symbolic links in the current working directory and detect any possible intrusions or unauthorized changes made to the monitored files and directories.
The application has the following main functionalities:
I.	Creation of files and directories: The script can create files and sub-directories with files in the current working directory which are supposed to be monitored
II.	Creation of a verification file: With the given correct option (-c), the script creates a verification file with filenames, full path, access mode in text format, owner ID, group ID, modification time, and file type, which will be one of the appropriate strings: regular file, directory or symbolic link.
III.	Creation of an output file: The script can also create a file with the current file attributes, which will be checked against the verification file to detect possible intrusion.
.




EXPLANATION OF THE MODULES IN THE SCRIPT
1.	Header Section
•	The script begins with a shebang (#!) to make it automatically run in the shell. Two hidden configuration files are defined: config_file and config_file2 to store the verification filename and the current output filename respectively. The verification name will be required by the script when it is run again
2.	displayUsage Function:
•	This module is responsible for displaying usage instructions to the user when the script is run with an invalid or missing parameter. It clearly outlines the options available and their respective usage. It then exits with a status of 1 so that the script stops executing.
3.	createFiles Function:
•	This function creates files and sub-directories in the current working directory to be monitored for elaboration purposes.
•	Two directories are created namely: my_dir and another_dir. An echo function is used to write information to files and store them in the directories at the same time. Several random text files are also created
4.	collectData Function:
•	The function checks if there are any configuration files and adds them to the exclusion list in the `find` function. The module finds all the files, symbolic links, and directories in the current working directory. It excludes certain files and file types such as README.md files, git-related directories, and the files created by this script. This is done by using the `! -name “filename” ` option.
5.	storeData Function:
•	This function calls the collectData function and stores it in a specified file. It receives one argument which is used to store the file attributes. MD5 checksums are also calculated for all regular files. The attributes stored include:
(i)	Full path and file name
(ii)	File type (regular file, directory, symlink)
(iii)	 Access mode in text format
(iv)	Owner ID and group ID
(v)	Time of last modification and last file status change
(vi)	 MD5 hash values
•	The data is collected using the following commands: 
(a)	$(ls -alF $i) – ls command to list the attributes passed in the option field
(b)	$(md5sum $i) | awk ‘{print $1}’ – Calculates MD5 checksums. The awk step removes the filename at the end
6.	deleteFiles Function:
•	This function checks if configuration files were created and deletes them together with all the files that were created by the application. The -f option deletes the files without warning.
7.	verify Function:
•	The function checks if the configuration files were created. The diff( -uBr $verification_file $curent_output) command is used to compare the current output file generated with the verification file. The `-uB` option is used to specify unified output and ignore blank lines, and the `-r` option compares the directories recursively. The value is stored in a variable which is used to determine if there have been any changes since the verification file was created. The differences are saved in a temporary file named diff.txt. The declare command declares an array named files to store information about the differences. The diff.txt file is then examined and the printVerificationStatus function to print out detailed information.
8.	pintVerificationStatus Function:
•	This module is used to report and handle differences found between the two files. It takes the parameters that describe the differences between the verification file and the current output.
•	The function starts by printing “Intrusion detected at $1”
•	It then checks the status of the 12th argument. If it is empty, it means there is no previous state to compare with. It then checks the file mode in the 2nd argument if it says the file has been added or deleted (+/-) and prints out the action, time and the individual who created it.
•	If there is a previous state, it compares the attributes and indicates the specific changes that have happened such as MD5 hash value changes, ownership change, timestamp change etc.

9.	Main Script Section:
•	When the script is executed, it checks if no arguments have been passed. If there are no arguments, it displays the usage information and stops the execution.
•	The script accepts the following command line options:
(i)	-i: 
Prints out “Creating file …”
Creates predefined files and directories
Prints out “Directories and files created”
(ii)	-c name1: 
Creates a verification file named `name1` (name1 passed as an argument by the user)
It also stores the name passed by the user to $config_file
(iii)	 -d: 
Deletes non-script-related files created by the application.
Calls the function deleteFile and prints out “Done”

(iv)	 -o name2: 
Creates an output file named `name2` (passed by the user). 
It also displays the contents of the file and does the verification of the file
It also stores the name passed by the user to $config_file2
•	The script also checks if no option or an invalid option is passed and displays the usage information.
•	The case command is used to handle the different options input by the user.
FINDINGS
•	The script was executed without any arguments being passed on the command line and the output was usage information.
 
•	Files were created with the ‘-i’ option as shown in the snapshot. Several files and directories were created. These files and directories are predefined within the script.
 
•	A verification file named “verification.txt” was created using the script on Git Bash and used as a screenshot of the directory being monitored. The -c option was used together with the name of the file on the command line. Details included in the file were:
 
Running ls -a command (a for all files including hidden folders) displayed the files that were created as seen in the snapshot below. 
 

•	The script was executed with the -o option and a file name passed on the command line to store the current output file. The current output file represents the attributes of the file when the script was being executed. This is the file that is supposed to be checked against the verification file.
 
The output file was stored in “current_output.txt” as shown in the snapshot above. Verification was done subsequently and no intrusions were detected at the time of execution.
•	To test if the script actually works, a new file was created and the script reran with the “-o” option. The same output file name was used.
 
Rerunning the script gave the following output:
 
Intrusion was detected as a result of new file being created.
•	After all the checks were done, the script was executed with the -d option to delete all the files that had been created. And then the ls command was used to verify that the files had been deleted.
 
 

 
SUMMARY AND CONCLUSION
The results of this intrusion detection script revealed the usefulness of this system in file monitoring. Differences between the verification file and the current output file were found when a new file was created. More differences would have been noted if the script had detected any other change in the directory being monitored. These changes include the deletion of existing files, modifications in file permissions, ownership changes, changes in timestamps, and differences in MD5 hash values.
"Intrusion detection is widely recognized as a powerful tool for protecting systems against malicious attacks (Ramprakash et al., 2014)." This script successfully fulfilled its purpose as a host-based intrusion detection system.
REFERENCES
Kidwai, A., Arya, C., Singh, P., Diwakar, M., Singh, S., Sharma, K. and Kumar, N., 2021. A comparative study on shells in Linux: A review. Materials Today: Proceedings, 37, pp.2612-2616.
Ou, Y.J., Lin, Y. and Zhang, Y., 2010, April. The design and implementation of host-based intrusion detection system. In 2010 third International Symposium on Intelligent Information Technology and Security Informatics (pp. 595-598). IEEE.
Ramprakash, P., Sakthivadivel, M., Krishnaraj, N. and Ramprasath, J., 2014. Host-based intrusion detection system using sequence of system calls. International Journal of Engineering and Management Research (IJEMR), 4(2), pp.241-247.

