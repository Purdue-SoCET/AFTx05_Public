##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################


rm -f out/top_chip.clean.v
cp out/top_chip.nopower.v out/top_chip.clean.v

sed -i 's/\.VDD(\\vdd\! ));//' out/top_chip.clean.v
sed -i 's/\.VSS(\\vss\! ),//' out/top_chip.clean.v
sed -i 's/\.VSSIO(VSSIO),//' out/top_chip.clean.v
sed -i 's/\.VDDIO(VDDIO),//' out/top_chip.clean.v
sed -i 's/	\\vdd\! , //'  out/top_chip.clean.v
sed -i 's/	\\vss\! , //'  out/top_chip.clean.v
sed -i 's/	VDDIO, //'  out/top_chip.clean.v
sed -i 's/	VSSIO);//'  out/top_chip.clean.v
sed -i 's/   inout \\vdd\! ;//' out/top_chip.clean.v
sed -i 's/   inout \\vss\! ;//' out/top_chip.clean.v
sed -i 's/   inout VDDIO;//' out/top_chip.clean.v
sed -i 's/   inout VSSIO;//' out/top_chip.clean.v
sed -i 's/pad),/pad));/' out/top_chip.clean.v
sed -i 's/   pad80_vdd PAD_VDD_\w (//' out/top_chip.clean.v
sed -i 's/   pad80_vss PAD_GND_\w (//' out/top_chip.clean.v
sed -i 's/   pad80_vddio PAD_VDDIO_\w (//' out/top_chip.clean.v
sed -i 's/   pad80_vssio PAD_VSSIO_\w (//' out/top_chip.clean.v
sed -i 's/   corner CORNER_\w\w (//' out/top_chip.clean.v




