#!python
#cython: boundscheck=False
#cython: wraparound=False
#cython: initializedcheck=False
#cython: profile=False

import numpy as np
cimport numpy as np
import os

from libc.stdio cimport FILE, fopen, fread, fwrite, fclose, stdin

def compressInput(fn, bwtDir):
    '''
    Compresses a BWT string from a file or STDIN using run-length encoding,
    and saves it as a NumPy .npy file for fast access.

    Parameters:
        fn (str or None): Path to input file containing BWT string. If None, reads from STDIN.
        bwtDir (str): Directory to save the compressed output.

    Returns:
        None
    '''
    cdef FILE * inputStream
    if fn is None:
        inputStream = stdin
    else:
        inputStream = fopen(fn.encode(), b"r")

    if not os.path.exists(bwtDir):
        os.makedirs(bwtDir)

    cdef str outputFN = bwtDir + '/comp_msbwt.npy'
    cdef FILE * outputStream = fopen(outputFN.encode(), b"w+")

    cdef unsigned long BUFFER_SIZE = 1024
    cdef bytes strBuffer = b'\x00' * BUFFER_SIZE
    cdef unsigned char * buffer = strBuffer

    # Reserve header space (96 bytes), initialize with ASCII 32 (' ') except for final newline
    cdef unsigned long headerSize = 96
    cdef bytes headerHex = b'\x56'

    cdef unsigned long x
    for x in range(0, headerSize - 1):
        buffer[x] = 32  # ' '
    buffer[headerSize - 1] = 10  # '\n'
    fwrite(buffer, 1, headerSize, outputStream)

    # Set up translation from symbol to numeric encoding
    cdef list validSymbols = ['$', 'A', 'C', 'G', 'N', 'T']
    cdef np.ndarray[np.uint8_t, ndim=1, mode='c'] translator = np.array([255] * 256, dtype=np.uint8)
    cdef np.uint8_t [:] translator_view = translator

    x = 0
    cdef str c
    for c in validSymbols:
        translator_view[ord(c)] = x
        x += 1

    cdef unsigned long readBytes = fread(buffer, 1, BUFFER_SIZE, inputStream)

    cdef unsigned char currSym = buffer[0]
    cdef unsigned long currCount = 0
    cdef unsigned char writeByte
    cdef unsigned long bytesWritten = 0

    while readBytes > 0:
        for x in range(0, readBytes):
            if currSym == buffer[x]:
                currCount += 1
            else:
                if translator_view[currSym] == 255:
                    if currSym == 10:
                        pass
                    else:
                        raise Exception('UNEXPECTED SYMBOL DETECTED: ' + chr(currSym))
                else:
                    while currCount > 0:
                        writeByte = translator_view[currSym] | ((currCount & 0x1F) << 3)
                        fwrite(&writeByte, 1, 1, outputStream)
                        currCount = currCount >> 5
                        bytesWritten += 1

                    currSym = buffer[x]
                    currCount = 1

        readBytes = fread(buffer, 1, BUFFER_SIZE, inputStream)

    # Handle last run
    if translator_view[currSym] == 255:
        if currSym == 10:
            pass
        else:
            raise Exception('UNEXPECTED SYMBOL DETECTED: ' + chr(currSym))
    else:
        while currCount > 0:
            writeByte = translator_view[currSym] | ((currCount & 0x1F) << 3)
            fwrite(&writeByte, 1, 1, outputStream)
            currCount = currCount >> 5
            bytesWritten += 1

    fclose(inputStream)
    fclose(outputStream)

    # Update header with actual .npy metadata
    npy_header = (
        b'\x93NUMPY\x01\x00' +
        headerHex +
        b'\x00' +
        ("{'descr': '|u1', 'fortran_order': False, 'shape': (%d,), }" % bytesWritten).encode()
    )

    buffer = npy_header
    cdef np.ndarray[np.uint8_t, ndim=1, mode='c'] mmapTemp = np.memmap(bwtDir + '/comp_msbwt.npy', dtype='<u1', mode='r+')
    cdef np.uint8_t [:] mmapTemp_view = mmapTemp
    for x in range(0, len(npy_header)):
        mmapTemp_view[x] = buffer[x]
