library(stringr)

s<-read.table("C:/Users/salva/Downloads/Sfa_angsd_analysis/angsd_notrans_snps_selection_it500_noinv_subset.selection")

## function for QQplot
qqchi<-function(x,...){
  lambda<-round(median(x)/qchisq(0.5,1),2)
  qqplot(qchisq((1:length(x)-0.5)/(length(x)),1),x,ylab="Observed",xlab="Expected",...);abline(0,1,col=2,lwd=2)
  legend("topleft",paste("lambda=",lambda))
}
#lambda is a measure of inflation in the data (often used in genetic association studies to assess the degree of deviation from the null hypothesis). It quantifies the ratio of the observed to expected medians and rounds it to 2 decimal places.
#This function is used to assess whether the observed data (in s$V1) follows the expected chi-squared distribution under the null hypothesis. Deviations from the diagonal line indicate departures from the null, and the lambda value quantifies the inflation of test statistics


qqchi(s$V1)

pval<-as.data.frame(1-pchisq(s$V1,1))

names(pval)="pval"

locs<-read.table("C:/Users/salva/Downloads/Sfa_angsd_analysis/global_snp_list_depth1_15_notrans.regions")

chr_loc=as.data.frame(str_split_fixed(locs$V1, ":", 2))

chr_loc_noinv=subset(chr_loc, V1!="NC_043748.1" & V1!="NC_043749.1" & V1!="NC_043750.1" & V1!="NC_043755.1" & V1!="NC_043758.1"  )

sites<-read.table("C:/Users/salva/Downloads/Sfa_angsd_analysis/angsd_notrans_snps_selection_it500_noinv_subset.sites")

chr_loc_kept=chr_loc_noinv[which(sites$V1==1),]

pval$chr=chr_loc_kept$V1

plot(-log10(pval$pval),col=as.factor(pval$chr),xlab="Chromosomes",ylab="Log10(p-value)",main="Manhattan plot",pch=16,cex=0.5)

nrow(pval)
#total number of SNPs: 11481558 

BF_threshold = 0.05/nrow(pval)
#4.35481e-09 acts as our threshold for significance 

abline(h=-log10(BF_threshold), lty=2)
#adds a line for the threshold onto the Manhattan plot

which(pval$pval<BF_threshold)
#792 SNPs are above that threshold. 

#psamp=pval[sample(nrow(pval), 10000), ]

#plot(-log10(psamp$pval),col=as.factor(psamp$chr),xlab="Chromosomes",ylab="Log10(p-value)",main="Manhattan plot",pch=16,cex=0.5)
