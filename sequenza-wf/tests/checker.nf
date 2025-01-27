#!/usr/bin/env nextflow

/*
  Copyright (c) 2021, ICGC-ARGO-Structural-Variation-CN-WG

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    lDesiree
*/

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

nextflow.enable.dsl = 2
version = '0.2.5'

// universal params
params.publish_dir = ""
params.container = ""
params.container_registry = ""
params.container_version = ""
params.cpus = 1
params.mem = 3  // GB

// tool specific parmas go here, add / change as needed
params.tumor_bam         = ""
params.normal_bam        = ""
params.gcwiggle          = ""
params.fasta             = ""
params.expected_segments = ""

params.cleanup = false

include { SequenzaWf } from '../main'

process file_smart_diff {
  input:
    path output_file
    path expected_file

  output:
    stdout()

  script:
    """
    # Note: this is only for demo purpose, please write your own 'diff' according to your own needs.
    # in this example, we need to remove date field before comparison eg, <div id="header_filename">Tue 19 Jan 2021<br/>test_rg_3.bam</div>
    # sed -e 's#"header_filename">.*<br/>test_rg_3.bam#"header_filename"><br/>test_rg_3.bam</div>#'

    cat ${output_file} \
      | sed -e 's#"header_filename">.*<br/>#"header_filename"><br/>#' > normalized_output

    ([[ '${expected_file}' == *.gz ]] && gunzip -c ${expected_file} || cat ${expected_file}) \
      | sed -e 's#"header_filename">.*<br/>#"header_filename"><br/>#' > normalized_expected

    diff normalized_output normalized_expected \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}


workflow checker {
  take:
    tumor_bam
    normal_bam
    fasta
    gcwiggle
    expected_segments

  main:
    SequenzaWf(
      tumor_bam,
      normal_bam,
      fasta,
      gcwiggle
    )

    file_smart_diff(
      SequenzaWf.out.segments,
      expected_segments
    )
}


workflow {
  checker(
    file(params.tumor_bam),
    file(params.normal_bam),
    file(params.fasta),
    file(params.gcwiggle),
    file(params.expected_segments)
  )
}
