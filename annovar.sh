#!/usr/bin/env bash

#SCRIPT:	annovar.sh
#AUTHOR:	Anurag Raj <anurag.raj@igib.in>
#DATE:	2018-11-23

#PURPOSE: To run certain commands for annovar tool

#Required: humandb directory containing all database and genelist.txt file

echo "*******************************************"
echo "Welcome to annovar command line analysis!!!"
echo "*******************************************"

echo "This script takes vcf as input file and"
echo "generates multi anno file and finally"
echo "applies certain filters. Please check"
echo "the required files humandb and genelist."
echo

echo "Enter the VCF file name: "

#reading filename
read vcfName

if [ -z $vcfName ]; then
  echo "Error: You haven't enter any VCF filename. Try again!!!"$'\n'
  exit
fi

if [ ! -e $vcfName ]; then
  echo $'\n'"Error: $vcfName file doesn't exist here!!!"$'\n'
  exit
fi

#parsing file name
vcf=$(echo $vcfName | cut -f1 -d'.')

if [ -d $vcf ] 
then
    echo $'\n'"Directory \"$vcf\" exists in the current directory. Rename the folder."$'\n'
    exit

else
    mkdir -p $vcf
	cd $vcf
fi

#avinput command
echo $'\n'"Converting vcf to avinput format..."$'\n'
convert2annovar.pl --format vcf4 ../$vcf.vcf --outfile $vcf.avinput --includeinfo --withzyg

#multi anno command
echo "Running multianno command..."$'\n'
table_annovar.pl $vcf.avinput ../humandb/ --buildver hg19 --outfile $vcf --protocol refGene,cytoBand,genomicSuperDups,exac03,esp6500siv2_all,1000g2015aug_all,snp138,ljb26_all,clinvar_20170905,gwasCatalog --operation g,r,r,f,f,f,f,f,f,r --nastring 0 --otherinfo


#to filter function refgenes
echo "Filtering function refgenes..."$'\n'
grep -vw "ncRNA_exonic\|ncRNA_exonic;splicing\|ncRNA_intronic\|ncRNA_splicing\|intronic\|intergenic\|downstream\|UTR3\|UTR5\|synonymous\|upstream" $vcf.hg19_multianno.txt > $vcf.hg19_func.refgene.txt

#to filter population frequency
###please find the column ExAC_ALL, esp6500siv2_all, 1000g2015aug_all in which these column are present
echo "Filetring population frequency..."$'\n'
awk -F "\t" '(NR==1) || ($13 < 0.05) && ($21 < 0.05) && ($22 < 0.05)' $vcf.hg19_func.refgene.txt > $vcf.hg19_popfreq.txt

#gene list filter
echo "Filtering genes..."$'\n'
grep -wFf ../genelist.txt $vcf.hg19_popfreq.txt > $vcf.hg19_genefilter.txt

echo "The final file is generated \"$vcf/$vcf.hg19_genefilter.txt\"."$'\n'

exit
