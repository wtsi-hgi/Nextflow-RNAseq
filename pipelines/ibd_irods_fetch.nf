#!/usr/bin/env nextflow
/*
vim: syntax=groovy
-*- mode: groovy;-*-
========================================================================================
                        A simple 1-step pipe to fetch data from irods 
========================================================================================
*/

nextflow.preview.dsl=2

include lostcause from '../Nextflow-RNAseq/modules/lostcause.nf' params(run: true, outdir: params.outdir,
						   runtag : params.runtag)
include iget from '../Nextflow-RNAseq/modules/irods.nf' params(run: true, outdir: params.outdir)

workflow {

    Channel.fromPath(params.samplefile)
	.splitCsv(header: true)
	.map { row -> tuple("${row.samplename}", "${row.sample}", "${row.study_id}") }
/*	.take(2) */
	.set{ch_to_iget}

    iget(ch_to_iget)
    iget.out.map{a,b,c -> [b]}.set{cram_ch}
    iget.out.map{a,b,c -> [c]}.set{crai_ch}
    //my_ch.view()
    
    publish:
    cram_ch to: "${params.outdir}/cram", enabled: true, mode: 'move', overwrite: true
    crai_ch to: "${params.outdir}/cram", enabled: true, mode: 'move', overwrite: true
}