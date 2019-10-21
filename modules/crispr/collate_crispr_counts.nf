params.run = true
params.runtag = 'runtag'

process collate_crispr_counts {
    tag "collate counts"
    // container "nfcore-rnaseq"
    publishDir "${params.outdir}/collate_counts", mode: 'symlink'
    memory = '20G'
    cpus 2
    time '300m'
    errorStrategy { task.attempt <= 3 ? 'retry' : 'ignore' }
    maxRetries 3

    when:
    params.run

    input:
    file(samplename_counts_txt_files)

    output:
    file("count_matrix.txt")
    file("fofn_countsfiles.txt")

    shell:
    """
    ls . | grep .counts.txt\$ > fofn_countsfiles.txt

    python3 ${workflow.projectDir}/bin/crispr/collate_counts.py fofn_countsfiles.txt
    """
}
