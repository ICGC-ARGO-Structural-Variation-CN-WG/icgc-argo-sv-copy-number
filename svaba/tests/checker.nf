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
    alvinwt
*/

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.2.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number.svaba'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.input_tumour_bam = ""
params.input_normal_bam = ""
params.ref_genome_gz = ""
params.dbsnp_file = ""
expected_file = "expected/expected.somatic.indel.vcf"

include { svaba } from '../main.nf'
include { getBwaSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main'

process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    path expected_file

  output:
    stdout()

  script:
    """
    cat ${output_file} | sed -e '/^##fileDate=[0-9]*/d' | sed -e '/^##source=svaba(v1.1.0).*/d' > normalized_output
    diff normalized_output expected.somatic.indel.vcf \
    && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}

workflow checker {
  take:
    input_tumour_bam
    input_normal_bam
    input_tumour_bai
    input_normal_bai
    ref_genome_gz
    ref_genome_gz_secondary_files
    dbsnp_file
    expected_output

  main:
    svaba(
	input_tumour_bam,
	input_normal_bam,
        input_tumour_bai,
        input_normal_bai,
	ref_genome_gz,
        ref_genome_gz_secondary_files,
	dbsnp_file
    )

    file_smart_diff(
      svaba.out.output_file,
      expected_output
    )
}

workflow {
  checker(
    file(params.input_tumour_bam),
    file(params.input_normal_bam),
    file(params.input_tumour_bai),
    file(params.input_normal_bai),
    file(params.ref_genome_gz),
    Channel.fromPath(getBwaSecondaryFiles(params.ref_genome_gz), checkIfExists: true).collect(),
    file(params.dbsnp_file),
    file(expected_file)
  )
}
