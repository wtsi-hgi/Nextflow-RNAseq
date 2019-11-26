params.run = true

process 'vireo' {
    tag "vireo $samplename"

    errorStrategy = { task.attempt <= 4 ? 'retry' : 'ignore' }
    cpus =   {  2 * Math.min(1, task.attempt) }
    memory = {  30.GB + 20.GB * (task.attempt-1) }
    maxRetries 4
    
    container "single_cell"
    publishDir "${params.outdir}/vireo/", mode: 'symlink'

    when:
    params.run 

    input:
    set val(samplename), file(cell_data), val(n_donor)
    
    output:
    set val(samplename), file("cellsnp_${samplename}") 

  script:
   """
export PATH=/opt/conda/envs/conda_env/bin:/opt/conda/bin:\$PATH
vireo -c $cell_data -N $n_donor -o vireo_${samplename}
   """
}