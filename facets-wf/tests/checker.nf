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
    Andrej Benjak
*/

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

nextflow.enable.dsl = 2
version = '0.2.0'

// universal params
params.publish_dir = ""
params.container = ""
params.container_registry = ""
params.container_version = ""

// tool specific parmas go here, add / change as needed
params.tumor = ""
params.normal = ""
params.dbsnp = ""
params.ref = ""
params.genome = ""
params.out_prefix = ""
params.expected_output = ""
params.cleanup = false

include { FacetsWf } from '../main'
include { getSecondaryFiles } from '../wfpr_modules/github.com/icgc-argo/data-processing-utility-tools/helper-functions@1.0.1/main.nf'


process file_smart_diff {
  input:
    path output_file
    path expected_file

  output:
    stdout()

  shell:
    '''
    tar -zxvf !{output_file} test.out
    diff $(basename -s .tgz !{output_file}).out !{expected_file} \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    '''
}


workflow checker {
  take:
    tumor
    normal
    dbsnp
    ref
    ref_idx
    expected_output

  main:
    FacetsWf(
      tumor,
      normal,
      dbsnp,
      ref,
      ref_idx
    )

    file_smart_diff(
      FacetsWf.out.results,
      expected_output
    )
}


workflow {
  checker(
    file(params.tumor),
    file(params.normal),
    file(params.dbsnp),
    file(params.ref),
    Channel.fromPath(getSecondaryFiles(params.ref, ['fai','gzi']), checkIfExists: false).collect(),
    file(params.expected_output)
  )
}
