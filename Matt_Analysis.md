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

## TAF2 OE EXONS FEATURES

### UPregulated exons

Get the exon features for these IDs from vast-tools.

```sh
grep -f TAF2_EXONS_UP.tab vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TEST_TAF2_EXONS_UP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/TAF2_EXONS_UP\t/' TEST_TAF2_EXONS_UP.tab
```

Create a `matt cmpr_exons` compatible table

```sh
matt get_vast TEST_TAF2_EXONS_UP.tab COORCOORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > TEST_TAF2_EXONS_UP_ANNO.tab
```

### DOWNregulated exons

Extract the information and coordinates of exons that are downregulated in TAF2 OE.

```sh
grep -f TAF2_EXONS_DOWN.tab vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TEST_TAF2_EXONS_DOWN.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/TAF2_EXONS_DOWN\t/' TEST_TAF2_EXONS_DOWN.tab
```

Create a `matt cmpr_exons` compatible table. (`ANNO` = "annotated")

```sh
matt get_vast TEST_TAF2_EXONS_DOWN.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > TEST_TAF2_EXONS_DOWN_ANNO.tab
```

### Analyse exonic feature

Combine the test and control events

```sh
matt add_rows TEST_TAF2_EXONS_UP_ANNO.tab TEST_TAF2_EXONS_DOWN_ANNO.tab
matt add_rows TEST_TAF2_EXONS_UP_ANNO.tab CONTROL_EXONS_AS_CR_CS.tab
```

Check number of events

```sh
cut -f 1 TEST_TAF2_EXONS_UP_ANNO.tab | sort | uniq -c | sort -k1nr | head -n -1
```

```sh
   1000 AS_NC
   1000 CR
   1000 CS
    296 TAF2_EXONS_DOWN
    270 TAF2_EXONS_UP
```

```sh
matt cmpr_exons TEST_TAF2_EXONS_UP_ANNO.tab START END SCAFFOLD STRAND GENEID /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf /no_backup/mirimia/genome_seqs/Hsa38_gDNA.fasta Hsap 150 GROUP[TAF2_EXONS_UP,TAF2_EXONS_DOWN,CR,AS_NC,CS] matt_exon_features_TAF2 -notrbts -colors:red,blue,white,lightgray,darkgray
```

run using `qsub` method (`qsub_job 1 12 1 `). Intron length seems to be longer in up-regulated exons.

## TAF2 INTRONS FEATURES

### UP

Extract the information and coordinates of exons that are downregulated in TAF2 OE.

```sh
grep -f TAF2_INTRONS_UP.tab vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TEST_TAF2_INTRON_UP.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/TAF2_INTRON_UP\t/' TEST_TAF2_INTRON_UP.tab
```

Create a `matt cmpr_exons` compatible table. (`ANNO` = "annotated")

```sh
matt get_vast TEST_TAF2_INTRON_UP.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > TEST_TAF2_INTRON_UP_ANNO.tab
```

### DOWN

```sh
grep -f TAF2_INTRONS_DOWN.tab vast_out/INCLUSION_LEVELS_FULL-hg38-12-v251.tab | cut -f 1-6 | sed -e $'1iGENE\tEVENT\tCOORD\tLENGTH\tFullCO\tCOMPLEX' > TEST_TAF2_INTRON_DOWN.tab
```

Add grouping

```sh
sed -i '1s/^/GROUP\t/; 2,$s/^/TAF2_INTRON_DOWN\t/' TEST_TAF2_INTRON_DOWN.tab
```

Create a `matt cmpr_exons` compatible table. (`ANNO` = "annotated")

```sh
matt get_vast TEST_TAF2_INTRON_DOWN.tab COORD FullCO COMPLEX LENGTH -gtf /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf > TEST_TAF2_INTRON_DOWN_ANNO.tab
```

### Testing for features enrichment

Combine the introns to test for features and the control intron events.

```sh
# combine first up and down regulated introns
matt add_rows TEST_TAF2_INTRON_UP_ANNO.tab TEST_TAF2_INTRON_DOWN_ANNO.tab 
# then add the control introns
matt add_rows TEST_TAF2_INTRON_UP_ANNO.tab CONTROL_INTRONS_AS_CR_CS.tab
```

Check how many events are in each group:

```sh
cut -f 1 TEST_TAF2_INTRON_UP_ANNO.tab | sort | uniq -c | sort -k1nr | head -n -1
```

```sh
   1000 AS_NC
   1000 CS
    126 TAF2_INTRON_UP
    102 TAF2_INTRON_DOWN
     50 CR
```

Now compare the events

```sh
matt cmpr_introns TEST_TAF2_INTRON_UP_ANNO.tab START END SCAFFOLD STRAND GENEID /no_backup/mirimia/genome_annots/ensembl/Hsa38.gtf /no_backup/mirimia/genome_seqs/Hsa38_gDNA.fasta Hsap 150 GROUP[TAF2_INTRON_UP,TAF2_INTRON_DOWN,CR,AS_NC,CS] matt_intron_features_TAF2 -notrbts -colors:red,blue,white,lightgray,darkgray
```

run using `qsub` method (`qsub_job 1 12 1 `). Intron length seems to be longer in up-regulated exons.

