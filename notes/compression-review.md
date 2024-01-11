# Compression


## To Sort
  * https://aclanthology.org/2023.findings-acl.426.pdf
  * https://rdrr.io/cran/shipunov/man/NC.dist.html
  * https://kenschutte.com/gzip-knn-paper/
  * https://codeconfessions.substack.com/p/decoding-the-acl-paper-gzip-and-knn
  * https://github.com/cyrilou242/ftcc


## gzip
https://en.wikipedia.org/wiki/Gzip

### memCompress() Implementation
gzip compression uses whatever is the default compression level of the underlying library (usually 6).

### zlib package Implementation
https://cran.r-project.org/web/packages/zlib/readme/README.html



## bzip2
https://en.wikipedia.org/wiki/Bzip2


### memCompress() Implementation
bzip2 compression always adds a header ("BZh"). The underlying library only supports in-memory (de)compression of up to 2^{31} - 1 elements. Compression is equivalent to `bzip2 -9` (the default).


## xz
https://en.wikipedia.org/wiki/XZ_Utils

### memCompress() Implementation
Compressing with type = "xz" is equivalent to compressing a file with `xz -9e` (including adding the ‘magic’ header): decompression should cope with the contents of any file compressed by xz version 4.999 and later, as well as by some versions of lzma. There are other versions, in particular ‘raw’ streams, that are not currently handled.
