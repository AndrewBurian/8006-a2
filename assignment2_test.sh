#!/bin/sh

#
#	Usage: ./assignment2_test.sh <IP_ADDRESS> [test file]
#

IP_ADDRESS=$1
TEST_COUNT=0
TEST_PASSED=0
TEST_FAILED=0
TEST_FILE="tests"

if [ $# -eq 2 ]
then
	TEST_FILE=$2
elif [ ! $# -eq 1 ]
then
	echo "Usage: $0 <IP_ADDRESS> [test file]"
	exit
fi

#check if the test file exists
if [ ! -f $TEST_FILE ]
then
	echo "Test file \"${TEST_FILE}\" does not exist."
	exit
fi

#create a new file descriptor for the tests file
exec 5< $TEST_FILE

while read description <&5
do
	
	#check to see if the line is empty
	if [ ${#description} -eq 0 ]
	then
		continue
	fi
	
	#read the test args of what the test is
	read test <&5
	
	#read the desired output of hping3
	read output <&5
	
	
	TEST_COUNT=$(($TEST_COUNT+1))
	echo -n "Test ${TEST_COUNT}..."
	
	#run the test and redirect the stdout and stderr to /dev/null so there is no text displayed
	hping3 $test -c 1 --tcpexitcode $IP_ADDRESS > /dev/null 2> /dev/null
	
	hping_value=$?
	
	#check if the test passed or failed
	if [ $hping_value -eq $output ]
	then
		echo "Passed: $description"
		TEST_PASSED=$(($TEST_PASSED+1))
	else
		echo "Failed got $hping_value : $description"
		echo "\t\thping3 $test $IP_ADDRESS"
		TEST_FAILED=$(($TEST_FAILED+1))
	fi
	
	echo ""
	
done < $TEST_FILE

echo ""
echo "Completed tests!"
echo "Passed: ${TEST_PASSED}/${TEST_COUNT}"
echo "Failed: ${TEST_FAILED}/${TEST_COUNT}"
