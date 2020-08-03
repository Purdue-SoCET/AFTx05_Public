

# Description
This repository explores the methods used by TensorFlow-Lite for creating machine learning models suitable for integer-only arithmetic. We have written C functions for inferencing using models limited to Conv1D and FullyConnected layers.

**lib_apb**: All software library files

**rtl_builder**: All files related to building the code for running
- pull the riscv tools using: ``` $ ./get_riscv_tools ```
- add riscv tools to your .bashrc as similar to the following:
```
export RISCV=~/rtl_builder/riscv-tools
export PATH=~/rtl_builder/riscv-tools/bin:$PATH
```
- run code using: ``` $ python src_to_rom.py myfilename.c ```

**periphs.tcl**: Basic waveform setup for viewing GPIO, PWM, Timer, and CRC

# Getting started
Running the make_tflite.py file will create a model.tflite file which can then be used to create the proper header files for running the model using our C code. After running make_tflite.py, run the modelHeaders.py file to update the files in the modelH directory. The .h files in that directory will be used by the C code. Once the .h files have been made you can overwrite the .h files in c_code/sim_model. The main file in this directory only tests using the img.h file. If you want to test all of the test data run write_files and use c_code/main_all.c

# Other Files
The following files where used for prototyping:

Look at Some MNIST.py

Train MNIST.py

integer_inference.py

run_homemade_int_inference.py

softmax.py

# References
https://github.com/google/gemmlowp

https://github.com/tensorflow/tensorflow/tree/master/tensorflow/lite

https://arxiv.org/abs/1712.05877

