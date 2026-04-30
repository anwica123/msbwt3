from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize
import numpy

extModules = [
    Extension('MUSCython.BasicBWT', ['src/MUSCython/BasicBWT.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.AlignmentUtil', ['src/MUSCython/AlignmentUtil.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.ByteBWTCython', ['src/MUSCython/ByteBWTCython.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.CompressToRLE', ['src/MUSCython/CompressToRLE.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.GenericMerge', ['src/MUSCython/GenericMerge.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.LCPGen', ['src/MUSCython/LCPGen.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.LZW_BWTCython', ['src/MUSCython/LZW_BWTCython.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.MSBWTCompGenCython', ['src/MUSCython/MSBWTCompGenCython.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.MSBWTGenCython', ['src/MUSCython/MSBWTGenCython.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.MultimergeCython', ['src/MUSCython/MultimergeCython.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.MultiStringBWTCython', ['src/MUSCython/MultiStringBWTCython.pyx'], include_dirs=['src', numpy.get_include()]),
    Extension('MUSCython.RLE_BWTCython', ['src/MUSCython/RLE_BWTCython.pyx'], include_dirs=['src', numpy.get_include()]),
]

setup(
    name='msbwt3',
    version='0.1.0',

    package_dir={"": "src"},
    packages=find_packages("src"),

    ext_modules=cythonize(
        extModules,
        compiler_directives={'language_level': "2"},
        include_path=['src']   
    ),

    install_requires=['numpy'],

    scripts=['bin/msbwt3'],
    zip_safe=False,
)