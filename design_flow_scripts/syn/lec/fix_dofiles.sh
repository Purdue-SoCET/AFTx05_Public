
##############################################################################
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################


sed -i 's/vpxmode//' ./top_level_bASIC/top_level_bASIC_lec*
sed -i 's/exit -f//' ./top_level_bASIC/top_level_bASIC_lec*
sed -i 's/\/.*\/MITLL90_STDLIB_8T.tt1p2v25c.lib/ \.\.\/MIT_STD_LEC.lib/' ./top_level_bASIC/top_level_bASIC_lec*
sed -i 's/ \.\.\/\.\.\// \.\.\/\.\.\/\.\.\/\.\.\//g' ./top_level_bASIC/top_level_bASIC_lec*
sed -i 's/fv/\.\.\/\.\.\/fv/' ./top_level_bASIC/top_level_bASIC_lec*
sed -i 's/\.\/out/\.\.\/\.\.\/out/' ./top_level_bASIC/top_level_bASIC_lec*


cp ./top_level_bASIC/top_level_bASIC_lec_rtl2mapped_dofile ./rtl2mapped/rtl2mapped_dofile
cp ./top_level_bASIC/top_level_bASIC_lec_mapped2final_dofile ./mapped2final/mapped2final_dofile
cp ./top_level_bASIC/top_level_bASIC_lec_rtl2final_dofile ./rtl2final/rtl2final_dofile

echo "diagnose -noneq -group -summary" >> ./rtl2mapped/rtl2mapped_dofile
echo "diagnose -noneq -group -summary" >> ./mapped2final/mapped2final_dofile
echo "diagnose -noneq -group -summary" >> ./rtl2final/rtl2final_dofile

echo "vpx save session rtl2mapped_session" >> ./rtl2mapped/rtl2mapped_dofile
echo "vpx save session mapped2final_session" >> ./mapped2final/mapped2final_dofile
echo "vpx save session rtl2final_session" >> ./rtl2final/rtl2final_dofile

