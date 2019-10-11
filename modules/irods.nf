params.run = true

process 'iget' {
    tag "iget $samplename"
    memory = '3G'
    time '120m'
    cpus 1
    maxForks 12
    errorStrategy { task.attempt <= 3 ? 'retry' : 'ignore' }
    maxRetries 3
    // Singularity nfcore-rnaseq.img:~> fastqc --version
    // FastQC v0.11.8
    
    // singularity pull --name nfcore-rnaseq.img docker://nfcore/rnaseq
    // have fastqc version FastQC v0.11.8, was pulled Thursday May 16th 2019
    // publishDir "${params.outdir}/STAR_2pass_bams/${samplename}/", mode: 'copy'
    publishDir "${params.outdir}/iget/", mode: 'symlink'

    when:
    params.run 

    input:
    set val(samplename), val(sample), val(study_id)
    
  output:
    set file("*.cram"), file ("*.crai") optional true

  script:
    """
imeta qu -z seq -d study_id = ${study_id} and sample = ${sample} and target = 1 | grep collection | awk -F ' ' '{print \$2}'` > collection.txt
imeta qu -z seq -d study_id = ${study_id} and sample = ${sample} and target = 1 | grep dataObj | awk -F ' ' '{print \$2}'` > dataObj.txt
paste -d '\/' collection.txt dataObj.txt > ${samplename}.${sample}.${studyid}.to_iget.txt

cat ${samplename}.${sample}.${studyid}.to_iget.txt | while read line
do
   iget -K --retries 2 -f -v \${line} ${samplename}.cram
   iget -K --retries 2 -f -v \${line}.crai ${samplename}.cram.crai
done
   """
}

//iget -K --retries 2 -f -v \$c ${sample}.cram
//iget -K --retries 2 -f -v \$c.crai ${sample}.cram.crai