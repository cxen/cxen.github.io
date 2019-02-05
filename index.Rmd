---
title: "Love Triangle: An Activity-Phylogeny-Function Relationship"
author: "Constantinos Xenophontos"
date: "February 19, 2019"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Family matters


## Including Plots


```{r echo=FALSE, message=FALSE, warning=FALSE}
##############################################################

# devtools::install_github("AckerDWM/gg3D")

library(openxlsx)
library(ggplot2)
library(plotly)
library(gg3D)
library(scatterplot3d)
library(RColorBrewer)

##############################################################

APF3D <- read.xlsx("C:/Users/Constantinos/Desktop/Mixed Cultures Experiment - 2018/Assay-25_Fluorescence Assays Rates/Clusters/Activity-Dissimilarity matrix.xlsx")

colnames(APF3D)[colnames(APF3D)=="Activity.change"] <- "Activity_change"
colnames(APF3D)[colnames(APF3D)=="Phyl..Distance"] <- "Phylogenetic_Diversity"
colnames(APF3D)[colnames(APF3D)=="Fun..Distance"] <- "Functional_Diversity"

APF3D.log <- APF3D

APF3D.log$Activity_change <- log10(APF3D$Activity_change+101)
# APF3D.log$Phylogenetic_Diversity <- log10(APF3D$Phylogenetic_Diversity)
# APF3D.log$Functional_Diversity <- log10(APF3D$Functional_Diversity)

##############################################################

# 2D plots

plot_ly(APF3D.log,
        x = ~Phylogenetic_Diversity, y = ~Functional_Diversity,
        type="scatter",
        text = paste("Community: ", APF3D$Label),
        mode = "markers",
        color = ~Group,
        size = ~Activity_change) %>%
  layout(xaxis = list(title = "Phylogenetic Dissimilarity"),
         yaxis = list(title = "Functional Dissimilarity"))

plot_ly(APF3D.log,
        x = ~Phylogenetic_Diversity, y = ~Activity_change,
        type="scatter",
        text = paste("Community: ", APF3D$Label),
        mode = "markers",
        color = ~Group,
        size = ~Functional_Diversity) %>%
  layout(xaxis = list(title = "Phylogenetic Dissimilarity"),
         yaxis = list(title = "EEA % change / log10"))

plot_ly(APF3D.log,
        x = ~Functional_Diversity, y = ~Activity_change,
        type="scatter",
        text = paste("Community: ", APF3D$Label),
        mode = "markers",
        color = ~Group,
        size = ~Phylogenetic_Diversity) %>%
  layout(xaxis = list(title = "Functional Dissimilarity"),
         yaxis = list(title = "EEA % change / log10"))

##############################################################

# 3D plots

attach(APF3D.log)
plot_ly(APF3D.log,
        x = ~Phylogenetic_Diversity, y = ~Activity_change, z = ~Functional_Diversity,
        color = ~Group,
        type = "scatter3d",
        mode = "markers",
        text = paste("Community: ", Label,
                      "</br> Activity %:", Activity_change)) %>%
  layout(scene = list(xaxis = list(title = "Phylogenetic Dissimilarity"),
                      yaxis = list(title = "EEA proportional change / log10"),
                      zaxis = list(title = "Functional Dissimilarity")))

##############################################################
```