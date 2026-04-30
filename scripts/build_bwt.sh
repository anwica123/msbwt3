#!/usr/bin/env bash
set -e

# =========================================================
# Build MSBWT
# =========================================================
# Usage:
#   ./build_bwt.sh <path_to_short_reads> <output_directory>
#
# Example:
#   scripts/build_bwt.sh data/small_fastq data/bwt_from_small_fastq
# =========================================================

READ_DIR=$1
OUT=$2
READ_LIST=""

mkdir -p "${OUT}"
mkdir -p tmp

for read in "${READ_DIR}"/*.fastq.gz
do
  READ_LIST="${READ_LIST} ${read}"
done


# Run MSBWT build command
gzip -dc ${READ_LIST}\
| awk '/^@/ {seq=""; inseq=1; next} /^\+/ {print seq; inseq=0; next} inseq {seq = seq $0}' \
| sort -S 50% -T ./tmp \
| tr NT TN \
| ropebwt2 -LR \
| tr NT TN \
| msbwt3 convert ${OUT}


echo "MSBWT build completed at: $OUT"
