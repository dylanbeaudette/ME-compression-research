## https://cran.r-project.org/web/packages/zlib/readme/README.html

library(zlib)
library(lorem)

set.seed(10101)
.text <- ipsum_words(10)

#
compressor <- zlib$compressobj(level = 9, method = zlib$DEFLATED, wbits = zlib$MAX_WBITS + 16)  

res <- c(
  compressor$compress(charToRaw(.text)),
  compressor$flush()
)

res

memCompress(.text, type = 'gzip')


## questions:
# * effect of wbits / window size ?
# * effect of level ?
# * better stability across platforms?


