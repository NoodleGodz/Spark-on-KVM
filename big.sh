
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <java_file> <data_file> <number_of_slaves>"
    exit 1
fi


java_file=$1
data_file=$2
numofslaves=$3


. ./sh/terra_custom.sh $3



