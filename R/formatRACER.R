#' Formating Data for Regional Association ComparER
#'
#' This group of functions allows you to creat a plot of -log10(P-values) of an association study by their genomic position, for example, the results of a GWAS or eQTL study. This function carries out the formatting necessary for your association data to be compatible with the plotting functions.
#' @param assoc_data required. A dataframe that has columns containing the chromosome, physical position, and p-values or -log10(p-values) of the association, and can optionally have columns containing R2 information for LD in the region, or rsID numbers for the associated SNPs.
#' @param chr_col required. numeric. index of column in assoc_data containing chromosome information.
#' @param pos_col required. numeric. index of column in assoc_data containing genomic position information.
#' @param log10p_col required, if no p_col specified. numeric. index of column in assoc_data containing -log10(p-value)s.
#' @param p_col required, if no log10p_col column specified. numeric. index of column in assoc_data containing p-values.
#' @param ld_col optional. numeric. Required if you want to use the LD data in your data set in your plot, index of column in assoc_data containing LD information, e.g. R2 or D' values
#' @param rs_col optional. numeric. Required if you want to use the use ldRACER to pull LD information from the 1000 genomes phase III project, or if you want to make a scatter comparison plot
#'
#' @keywords association plot linkage disequilibrium
#' @concept GWAS
#' @export
#' @examples
#' data(mark3_bmd_gwas)
#' head(formatRACER(assoc_data = mark3_bmd_gwas, chr_col = 3, pos_col = 4, p_col = 11, rs_col = 2))

formatRACER <- function(assoc_data, chr_col, pos_col, p_col=NULL, log10p_col=NULL, ld_col=NULL, rs_col = NULL){

  if(missing(chr_col)){
    stop("Please specify which column contains chromosome information.")
  }else if(missing(pos_col)){
    stop("Please specify which column contains genomic position information.")
  }else if(is.null(log10p_col) && is.null(p_col)){
    stop("Please specify which column contains p-values or -log10(p-values).")
  }

  message("Formating association data...")
  if(class(chr_col) == "numeric"){
    colnames(assoc_data)[chr_col] = "CHR"
  }else if(class(chr_col) == "character"){
    if((chr_col %in% colnames(assoc_data) == TRUE)){
      colnames(assoc_data)[which(colnames(assoc_data) == chr_col)] = "CHR"
    }else{
      stop("The chromosome column you specified is not in the association data frame.")
    }
  }
  if(class(pos_col) == "numeric"){
    colnames(assoc_data)[pos_col] = "POS"
  }else if(class(pos_col) == "character"){
    if((pos_col %in% colnames(assoc_data) == TRUE)){
      colnames(assoc_data)[which(colnames(assoc_data) == pos_col)] = "POS"
    }else{
      stop("The position column you specified is not in the association data frame.")
    }
  }
  message("Processing -log10(p-values)...")
  if(!is.null(log10p_col)){
    if(class(log10p_col) == "numeric"){
      colnames(assoc_data)[log10p_col] = "LOG10P"
    }else if(class(log10p_col) == "character"){
      if((log10p_col %in% colnames(assoc_data) == TRUE)){
        colnames(assoc_data)[which(colnames(assoc_data) == log10p_col)] = "LOG10P"
      }else{
        stop("The -log10p column you specified is not in the association data frame.")
      }
    }
  }else if(!is.null(p_col)){
    if(class(p_col) == "numeric"){
      colnames(assoc_data)[p_col] = "P"
    }else if(class(p_col) == "character"){
      if((p_col %in% colnames(assoc_data) == TRUE)){
        colnames(assoc_data)[which(colnames(assoc_data) == p_col)] = "P"
      }else{
        stop("The p-value column you specified is not in the association data frame.")
      }
    }
    assoc_data$LOG10P = -log10(assoc_data$P)
  }
  if(!is.null(rs_col)){
    if(class(rs_col) == "numeric"){
      colnames(assoc_data)[rs_col] = "RS_ID"
    }else if(class(rs_col) == "character"){
      if((rs_col %in% colnames(assoc_data) == TRUE)){
        colnames(assoc_data)[which(colnames(assoc_data) == rs_col)] = "RS_ID"
      }else{
        stop("The rsID column you specified is not in the association data frame.")
      }
    }
  }
  if(!is.null(ld_col)){
    message("Processing input LD information...")
    if(class(ld_col) == "numeric"){
      colnames(assoc_data)[ld_col] = "LD"
    }else if(class(ld_col) == "character"){
      if((ld_col %in% colnames(assoc_data) == TRUE)){
        colnames(assoc_data)[which(colnames(assoc_data) == ld_col)] = "LD"
      }else{
        stop("The LD column you specified is not in the association data frame.")
      }
    }
    assoc_data$LD = as.numeric(as.character(assoc_data$LD))
    assoc_data$LD_BIN <- cut(assoc_data$LD,
                      breaks=c(0,0.2,0.4,0.6,0.8,1.0),
                      labels=c("0.2-0.0","0.4-0.2","0.6-0.4","0.8-0.6","1.0-0.8"))
    assoc_data$LD_BIN = as.character(assoc_data$LD_BIN)
    assoc_data$LD_BIN[is.na(assoc_data$LD_BIN)] <- "NA"
    assoc_data$LD_BIN = as.factor(assoc_data$LD_BIN)
    assoc_data$LD_BIN = factor(assoc_data$LD_BIN, levels = c("1.0-0.8", "0.8-0.6", "0.6-0.4", "0.4-0.2", "0.2-0.0", "NA"))
  }

  # read in, format, and filter data sets
  message("Preparing association data...")
  assoc_data <- as.data.frame(assoc_data)
  assoc_data$POS = as.numeric(as.character(assoc_data$POS))
  assoc_data$LOG10P = as.numeric(as.character(assoc_data$LOG10P))
  assoc_data$CHR = as.numeric(as.character(assoc_data$CHR))

  return(assoc_data)
}

