"""
=========================================================
MSBWT Usage Guide (Python API)
=========================================================

This file contains examples for using the MSBWT Python API.

It is NOT meant to be imported as a library.
Just run sections or copy snippets as needed.
=========================================================
"""

# ---------------------------------------------------------
# Import MSBWT
# ---------------------------------------------------------
import MUSCython.MultiStringBWTCython as MultiStringBWT

# Load MSBWT instance
#msbwt = MultiStringBWT.loadBWT('/path/to/directory')

msbwt = MultiStringBWT.loadBWT('data/small_bwt')

# ---------------------------------------------------------
# 1. Count occurrences of a single k-mer
# ---------------------------------------------------------
kmer = 'CATACGTA'
count = msbwt.countOccurrencesOfSeq(kmer.encode())
print("Count:", count)

# ---------------------------------------------------------
# 2. Reverse complement of a k-mer
# ---------------------------------------------------------
rev_kmer = MultiStringBWT.reverseComplement(kmer)
print("Reverse complement:", rev_kmer)

# ---------------------------------------------------------
# 3. Find indices of a k-mer
# ---------------------------------------------------------
lo1, hi1 = msbwt.findIndicesOfStr(kmer.encode())

lo2, hi2 = msbwt.findIndicesOfStr(
    MultiStringBWT.reverseComplement(kmer).encode()
)

total_occurrence = (hi1 - lo1) + (hi2 - lo2)

print("Forward range:", lo1, hi1)
print("Reverse range:", lo2, hi2)
print("Total occurrence:", total_occurrence)

# ---------------------------------------------------------
# 4. Extract reads containing a k-mer
# ---------------------------------------------------------
fwd_ind = list(range(lo1, hi1))
rev_ind = list(range(lo2, hi2))

forward_reads = [
    msbwt.recoverString(i).decode() for i in fwd_ind
]

reverse_reads = [
    MultiStringBWT.reverseComplement(
        msbwt.recoverString(i).decode()
    )
    for i in rev_ind
]

print("Forward reads:", len(forward_reads))
print("Reverse reads:", len(reverse_reads))
