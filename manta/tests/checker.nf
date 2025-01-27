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
    Alvaro Ferriz
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
    'ghcr.io': 'ghcr.io/icgc-argo-structural-variation-cn-wg/icgc-argo-sv-copy-number.manta'
]
default_container_registry = 'ghcr.io'
/********************************************************************/

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.normalBam = ""
params.tumorBam = ""
params.referenceFasta = ""
params.normalBai = ""
params.tumorBai = ""
params.referenceFai = ""
params.runDir = ""
params.expected_output = ""
params.available_memory = ""

include { getSecondaryFiles } from './wfpr_modules/github.com/icgc-argo-workflows/data-processing-utility-tools/helper-functions@1.0.1.1/main.nf'
include { manta } from '../main'


process file_smart_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_file
    path expected_file

  output:
    stdout()

  script:
    """
    #For the comparison of VCFs files produced by manta, we need to remove several fields of the header. 
    #For simplicity reasons, the following test will compare one of the main outputs of manta (somaticSV.vcf) and will not consider the header at all. 
    #Further versions will also include other output files and specific header tags.

    zcat ${output_file}/results/variants/somaticSV.vcf.gz| grep -v "#" > normalized_output
    zcat ${expected_file} | grep -v "#" > normalized_expected

    diff normalized_output normalized_expected \
      && ( echo "Test PASSED" && exit 0 ) || ( echo "Test FAILED, output file mismatch." && exit 1 )
    """
}


workflow checker {
  take:
    normalBam
    tumorBam 
    referenceFasta
    normalBai
    tumorBai 
    referenceFai
    expected_output

  main:
    manta(
      normalBam,
      tumorBam,
      referenceFasta,
      normalBai,
      tumorBai,  
      referenceFai,
    
    )

    file_smart_diff(
      manta.out.output_file,
      expected_output
    )
}


workflow {
  checker(
    
    file(params.normalBam),
    file(params.tumorBam), 
    file(params.referenceFasta),
    Channel.fromPath(getSecondaryFiles(params.normalBam,['bai']), checkIfExists: true).collect(),
    Channel.fromPath(getSecondaryFiles(params.tumorBam,['bai']), checkIfExists: true).collect(),
    Channel.fromPath(getSecondaryFiles(params.referenceFasta,['fai']), checkIfExists: true).collect(),  
    file(params.expected_output)
  )
}
