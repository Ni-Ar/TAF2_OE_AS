```sh
cd projects/01_ALTdemix/data/INCLUSION_tbl/Tanja/vast_tools
```

Create a control set of events

Remove events with`NA` in PSI, which is the last column (so I can use `$` in the `grep -v` regex) 

```sh
cut -f 1-4,6-7 vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | tail -n +2 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tCOMPLEX\tPSI' | grep -v "NA$" > Control_PSI_n505868.tab
```

Ended up not really using the table above.

## General useful paths for this analysis

Human gtf file:

```sh
/no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf
```

Human genome fasta seq file

```sh
/no_backup/mirimia/genome_seqs/Hsa38_gDNA.fasta 
```

## Create exons control sets

Create sets of 1000 exons in different categories.

AS non constitutive (ASNC)

```sh
matt add_val vast_out/compare_2023_08_01/min_dPSI15_min_range0_max_dPSI5/AS_NC-HeLa_TAF2OE_vs_CNTRL_uniq_noB3_pIR-Max_dPSI5.tab GROUP AS_NC | grep -P "(HsaEX|EVENT)" | matt rand_rows - 1000 > temp_ASNC.tab
```

Cryptic exons (CR)

```sh
matt add_val vast_out/compare_2023_08_01/min_dPSI15_min_range0_max_dPSI5/CR-HeLa_TAF2OE_vs_CNTRL_uniq_noB3_pIR.tab GROUP CR | grep -P "(HsaEX|EVENT)" | matt rand_rows - 1000 > temp_CR.tab
```

Constitutively spliced (CS)

```sh
matt add_val vast_out/compare_2023_08_01/min_dPSI15_min_range0_max_dPSI5/CS-HeLa_TAF2OE_vs_CNTRL_uniq_noB3_pIR.tab GROUP CS | grep -P "(HsaEX|EVENT)" | matt rand_rows - 1000 > temp_CS.tab
```

merge all in 1 file

```sh
tail -n +2 temp_CR.tab | cat temp_ASNC.tab - > temp_ASNC_CR.tab
tail -n +2 temp_CS.tab | cat temp_ASNC_CR.tab - | cut -f 1-6,32 > temp_all.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast temp_all.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > CONTROL_EXONS_AS_CR_CS.tab
```

## Create introns control sets

Create sets of 1000 exons in different categories.

AS non constitutive (ASNC)

```sh
matt add_val vast_out/compare_2023_08_01/min_dPSI15_min_range0_max_dPSI5/AS_NC-HeLa_TAF2OE_vs_CNTRL_uniq_noB3_pIR-Max_dPSI5.tab GROUP AS_NC | grep -P "(HsaIN|EVENT)" | matt rand_rows - 1000 > temp_ASNC_INTRONS.tab
```

Cryptic exons (CR)

```sh
matt add_val vast_out/compare_2023_08_01/min_dPSI15_min_range0_max_dPSI5/CR-HeLa_TAF2OE_vs_CNTRL_uniq_noB3_pIR.tab GROUP CR | grep -P "(HsaIN|EVENT)" | matt rand_rows - 1000 > temp_CR_INTRON.tab
```

Constitutively spliced (CS)

```sh
matt add_val vast_out/compare_2023_08_01/min_dPSI15_min_range0_max_dPSI5/CS-HeLa_TAF2OE_vs_CNTRL_uniq_noB3_pIR.tab GROUP CS | grep -P "(HsaIN|EVENT)" | matt rand_rows - 1000 > temp_CS_INTRON.tab
```

merge all in 1 file. Column 32 is the `GROUP` columns

```sh
tail -n +2 temp_CR_INTRON.tab | cat temp_ASNC_INTRONS.tab - > temp_ASNC_CR.tab
tail -n +2 temp_CS_INTRON.tab | cat temp_ASNC_CR.tab - | cut -f 1-6,32 > temp_all.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast temp_all.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > CONTROL_INTRONS_AS_CR_CS.tab
```

# EXONS FEATURES

```sh
cd ../diff_spliced_IDs/
```

### 1) UP-regulated exons in both TAF2 and NLS-TAF2∆IDR OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 1_UP_EXONS_BOTH.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/UP_EXONS_BOTH\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 1_UP_EXONS_BOTH_ANNO.tab
```

### 2) DOWNregulated exons in both TAF2 and NLS-TAF2∆IDR OE

Extract the information and coordinates of exons that are downregulated in TAF2 OE.

```sh
grep -f 2_DOWN_EXONS_BOTH.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/DOWN_EXONS_BOTH\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table. (`ANNO` = "annotated")

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 2_DOWN_EXONS_BOTH_ANNO.tab
```

### 3) UP-regulated exons only in TAF2 OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 3_UP_EXONS_TAF2.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/UP_EXONS_TAF2\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 3_UP_EXONS_TAF2_ANNO.tab
```

### 4) DOWN-regulated exons only in TAF2 OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 4_DOWN_EXONS_TAF2.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/DOWN_EXONS_TAF2\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 4_DOWN_EXONS_TAF2_ANNO.tab
```

### 5) UP-regulated exons only in NLS-TAF2∆IDR OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 5_UP_EXONS_TAF2dIDR.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/UP_EXONS_TAF2dIDR\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 5_UP_EXONS_TAF2dIDR_ANNO.tab
```

### 6) DOWN-regulated exons only in NLS-TAF2∆IDR OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 6_DOWN_EXONS_TAF2dIDR.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/DOWN_EXONS_TAF2dIDR\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 6_DOWN_EXONS_TAF2dIDR_ANNO.tab
```

```sh
rm TMP.tab
```

## Analyse exonic feature

```sh
cp 1_UP_EXONS_BOTH_ANNO.tab ALL_EXONS.tab
```

Combine the test and control events

```sh
matt add_rows ALL_EXONS.tab 2_DOWN_EXONS_BOTH_ANNO.tab
matt add_rows ALL_EXONS.tab 3_UP_EXONS_TAF2_ANNO.tab
matt add_rows ALL_EXONS.tab 4_DOWN_EXONS_TAF2_ANNO.tab
matt add_rows ALL_EXONS.tab 5_UP_EXONS_TAF2dIDR_ANNO.tab
matt add_rows ALL_EXONS.tab 6_DOWN_EXONS_TAF2dIDR_ANNO.tab
matt add_rows ALL_EXONS.tab ../vast_tools/CONTROL_EXONS_AS_CR_CS.tab
```

Check number of events

```sh
cut -f 1 ALL_EXONS.tab | sort | uniq -c | sort -k1nr | head -n -1
```

```sh
   1000 AS_NC
   1000 CR
   1000 CS
    192 DOWN_EXONS_TAF2
    177 DOWN_EXONS_TAF2dIDR
    159 UP_EXONS_TAF2
    147 UP_EXONS_TAF2dIDR
     80 UP_EXONS_BOTH
     72 DOWN_EXONS_BOTH
```

The last group `CS` is the reference. Run using `qsub`.

```sh
qsub -q long-centos79,short-centos79 -V -cwd -pe smp 4 -terse -l virtual_free=12G -l h_rt=02:30:15 -N matt_exon_features -m bea -M niccolo.arecco@crg.eu -b y matt cmpr_exons ALL_EXONS.tab START END SCAFFOLD STRAND GENEID /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf /no_backup/mirimia/genome_seqs/Hsa38_gDNA.fasta Hsap 150 GROUP[UP_EXONS_BOTH,UP_EXONS_TAF2,UP_EXONS_TAF2dIDR,DOWN_EXONS_BOTH,DOWN_EXONS_TAF2,DOWN_EXONS_TAF2dIDR,CR,AS_NC,CS] EXONS_FEATURES -notrbts -colors:red,red,red,blue,blue,blue,white,lightgray,darkgray
```

 Intron length seems to be longer in up-regulated exons.

# INTRONS FEATURES

### 1) UP-regulated introns in both TAF2 and NLS-TAF2∆IDR OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 1_UP_INTRONS_BOTH.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/UP_INTRONS_BOTH\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 1_UP_INTRONS_BOTH_ANNO.tab
```

### 2) DOWNregulated introns in both TAF2 and NLS-TAF2∆IDR OE

Extract the information and coordinates of exons that are downregulated in TAF2 OE.

```sh
grep -f 2_DOWN_INTRONS_BOTH.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/DOWN_INTRONS_BOTH\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table. (`ANNO` = "annotated")

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 2_DOWN_INTRONS_BOTH_ANNO.tab
```

### 3) UP-regulated introns only in TAF2 OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 3_UP_INTRONS_TAF2.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/UP_INTRONS_TAF2\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 3_UP_INTRONS_TAF2_ANNO.tab
```

### 4) DOWN-regulated introns only in TAF2 OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 4_DOWN_INTRONS_TAF2.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/DOWN_INTRONS_TAF2\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 4_DOWN_INTRONS_TAF2_ANNO.tab
```

### 5) UP-regulated introns only in NLS-TAF2∆IDR OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 5_UP_INTRONS_TAF2dIDR.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/UP_INTRONS_TAF2dIDR\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 5_UP_INTRONS_TAF2dIDR_ANNO.tab
```

### 6) DOWN-regulated introns only in NLS-TAF2∆IDR OE

Get the exon features for these IDs from vast-tools.

```sh
grep -f 6_DOWN_INTRONS_TAF2dIDR.tab ../vast_tools/vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TMP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/DOWN_INTRONS_TAF2dIDR\t/' TMP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TMP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > 6_DOWN_INTRONS_TAF2dIDR_ANNO.tab
```

```sh
rm TMP.tab
```

## Analyse Intronic features

```sh
cp 1_UP_INTRONS_BOTH_ANNO.tab ALL_INTRONS.tab
```

Combine the test and control events

```sh
matt add_rows ALL_INTRONS.tab 2_DOWN_INTRONS_BOTH_ANNO.tab
matt add_rows ALL_INTRONS.tab 3_UP_INTRONS_TAF2_ANNO.tab
matt add_rows ALL_INTRONS.tab 4_DOWN_INTRONS_TAF2_ANNO.tab
matt add_rows ALL_INTRONS.tab 5_UP_INTRONS_TAF2dIDR_ANNO.tab
matt add_rows ALL_INTRONS.tab 6_DOWN_INTRONS_TAF2dIDR_ANNO.tab
matt add_rows ALL_INTRONS.tab ../vast_tools/CONTROL_INTRONS_AS_CR_CS.tab
```

Check number of events

```sh
cut -f 1 ALL_INTRONS.tab | sort | uniq -c | sort -k1nr | head -n -1
```

```sh
   1000 AS_NC
   1000 CS
    102 UP_INTRONS_TAF2
     78 UP_INTRONS_TAF2dIDR
     73 DOWN_INTRONS_TAF2dIDR
     67 DOWN_INTRONS_TAF2
     50 CR
     32 DOWN_INTRONS_BOTH
     18 UP_INTRONS_BOTH
```

The last group `CS` is the reference. Run using `qsub`.

```sh
qsub -q long-centos79,short-centos79 -V -cwd -pe smp 4 -terse -l virtual_free=12G -l h_rt=02:30:15 -N matt_intron_features -m bea -M niccolo.arecco@crg.eu -b y matt cmpr_introns ALL_INTRONS.tab START END SCAFFOLD STRAND GENEID /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf /no_backup/mirimia/genome_seqs/Hsa38_gDNA.fasta Hsap 150 GROUP[UP_INTRONS_BOTH,UP_INTRONS_TAF2,UP_INTRONS_TAF2dIDR,DOWN_INTRONS_BOTH,DOWN_INTRONS_TAF2,DOWN_INTRONS_TAF2dIDR,CR,AS_NC,CS] INTRONS_FEATURES -notrbts -colors:red,red,red,blue,blue,blue,white,lightgray,darkgray
```



