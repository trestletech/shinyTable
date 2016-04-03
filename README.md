shinyTable
==========

> WARNING: I don't have time to actively develop this project right now. I'll do my best to review pull requests and am open to taking on new collaborators/maintainers. Another alternative project to check out is https://github.com/jrowen/rhandsontable

An R package that integrates Shiny with Handsontable. This package takes the 
unique approach of intelligently calculating the data *that has changed* 
on either the client or the server and sending only that data.

The goal of the project is to provide full support for data.frames (including
attributes and data types), seamlessly serializing and deserializing these
data structures to/from the client for you. Of course, we intend to be
compatible with matrices and other table-like structures in R.

We'll expose as many Handsontable configuration options as is reasonably 
possible including things like sortable, resizeable, and rearrangeable
columns. We hope to fluidly incorporate data validation and other 
advanced features, as well.


## Installation

You can install the latest version of the code using the `devtools` R package.

```
# Install devtools, if you haven't already.
install.packages("devtools")

library(devtools)
install_github("trestletech/shinyTable")
```

## Examples

There are a few example provided in the `inst/examples` directory of this repository. You can run them using commands like:

```r
runApp(system.file("examples/01-simple", package="shinyTable"))
```

Other examples include `02-matrix` and `03-click-input`. See the directory for a complete list.

## License

The development of this project was generously sponsored by the [Institut de 
Radioprotection et de Sûreté Nucléaire](http://www.irsn.fr/EN/Pages/home.aspx) 
and performed by [Jeff Allen](http://trestletech.com). The code is
licensed under The MIT License (MIT).

Copyright (c) 2013 Institut de Radioprotection et de Sûreté Nucléaire

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
