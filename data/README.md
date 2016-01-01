## Suggested data structure for BWASP workflow execution

The initial workflow steps will take downloaded or users-supplied BS-seq reads,
apply various filtering steps for data quality control, then map the reads to
the genome and call methylation status.  Statistical criteria are applied to
identify _highly supported methylation_ (hsm) sites.

A common experiment involves multiple samples and replicates.  In typical BWASP
usage, each replicate is analyzed separately before results from the replicates
are merged for each sample.  An appropriate directory structure for such
scenario can be generated with the __xmkdirstr__ scripts in this directory.

#### Example:

```
xmkdirstr myspecies study1 sample1 3 p
```

will generate the following directory structure:

```
myspecies:
genome	study1

myspecies/genome:
Makefile_parse_GFF3_template

myspecies/study1:
sample1

myspecies/study1/sample1:
Makefile_merge3_template  replicate1  replicate2  replicate3

myspecies/study1/sample1/replicate1:
genome	Makefile_WF1-6pe_template

myspecies/study1/sample1/replicate2:
genome	Makefile_WF1-6pe_template

myspecies/study1/sample1/replicate3:
genome	Makefile_WF1-6pe_template
```

The above assumes that _sample1_ in _study1_ has 3 replicates.  To add directories
for _sample2_ with 2 replicates, run the following command next:

```
xmkdirstr myspecies study1 sample2 2 s
```

giving overall:

```
myspecies:
genome	study1

myspecies/genome:
Makefile_parse_GFF3_template

myspecies/study1:
sample1  sample2

myspecies/study1/sample1:
Makefile_merge3_template  replicate1  replicate2  replicate3

myspecies/study1/sample1/replicate1:
genome	Makefile_WF1-6pe_template

myspecies/study1/sample1/replicate2:
genome	Makefile_WF1-6pe_template

myspecies/study1/sample1/replicate3:
genome	Makefile_WF1-6pe_template

myspecies/study1/sample2:
Makefile_merge2_template  replicate1  replicate2

myspecies/study1/sample2/replicate1:
genome	Makefile_WF1-6se_template

myspecies/study1/sample2/replicate2:
genome	Makefile_WF1-6se_template
```

#### Comments:
1. The _genome_ directory is expected by the [Bismark](http://www.bioinformatics.babraham.ac.uk/projects/bismark/)
software.  You should deposit the genome assembly of _myspecies_ into the _genome_
directory as &lt;species\_label&gt;.gdna.fa (and no other \*.fa files).

2. Template _makefiles_ were copied into the _replicate_ directories.  The _p_
argument in the first invocation of the _xmkdirstr_ command was used to indicate
that _sample1_ replicates comprise paired-end read data, wheres the _s_ argument
in the second command invocation was used to copy the template _makefile_ for
single-read data analysis.

3. Obviously, you will need to edit the _makefile_ templates appropriate to
your needs, but then you should be good to go.  The _makefile_ templates are from the [../bin/ directory](../bin/0README); please
follow the instructions there on how to edit the _makefiles_.

4. In particular, __make sure that your computer has enough resources__ to do
what is asked in the _makefiles_.  Execute some test runs and monitor CPU, memory,
and disk usage.
