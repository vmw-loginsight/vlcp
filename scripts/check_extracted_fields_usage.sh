#!/bin/bash

# This script is intended to show extracted field list that are not using
# with any of the widgets/alerts. It is important to identify extracted fields 
# that are not using as big number of extracted fields may have impact on 
# the vRLI performance.

# USAGE:
#  ./check_extracted_fields_usage.sh <content pack vlcp file path>


# TODO: add validation for imput paremeters.

egrep '\"(chartQuery|messageQuery)\"' "${1}" | egrep -o 'displayName\\?\":\\?\"[^\"]+' | cut -d"\"" -f3 | sort -u > used_fileds_tmp
egrep '^\s+\"displayName' "${1}" | cut -d"\"" -f4 | sort -u > define_fileds_tmp
echo ""
echo "USED EXTRACTED FIELDS                           | DEFINED EXRACTED FIELDS"
echo "-------------------------------------------------------------------------"
diff -y ./used_fileds_tmp ./define_fileds_tmp
rm -rf ./used_fileds_tmp ./define_fileds_tmp
#echo ${ext_filed[@]}
