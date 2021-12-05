setwd("C:/Users/Xutong Wu/Desktop/SDG/SDG network/数据分析")
data_in=read.csv('SDG country 2020.csv',head=T,row.names=1)
data=data_in[,3:19]

# Raw correlations (flattenCorrMatrix) ####
# Function to transform correlations matrices to "list" format (i.e. from/to/corr) 
# http://www.sthda.com/english/wiki/correlation-matrix-a-quick-start-guide-to-analyze-format-and-visualize-a-correlation-matrix-using-r-software#correlation-matrix-with-significance-levels-p-value 
# cormat : matrix of the correlation coefficients
# pmat : matrix of the correlation p-values
library(Hmisc)
library(data.table)
library(igraph)
library(vegan)

flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame( row = rownames(cormat)[row(cormat)[ut]],
              column = rownames(cormat)[col(cormat)[ut]],
              cor  =(cormat)[ut],
              p = pmat[ut])}

# Network metrics (developed specifically for the analyses of this paper) ####

# Function to calculate network metrics; windows move 1 plot at a time until a window reaches the plot with highest SDG to avoid rolling over the low SDG plots.
# if a particular block of networks give problems can be excluded modifying the function where indicated
# usage:  metrics <- Network_metrics (np=150, mws=60,data=data_Grass_select,Vertices=vertex_info_grass, estimate="POS",correlation="RAW")
# xxxxxxxxxxx <- metrics$Select.Net.metrics_final
# xxxxxxxxxxx <- metrics$Select.Node.metrics_final
# xxxxxxxxxxx <- metrics$Select.Net.matrix_final
# xxxxxxxxxxx <- metrics$Select.Net
# xxxxxxxxxxx <- metrics$edges.list

# np:  number of plots
# mws: moving window size
# nn = c(1:(np-(mws-1)))  # network number
# data: your dataset
### vertices: vertex info --> can be subset as Vertices=subset (vertex_info_grass,Node_type =="BD" | Node_type =="EF")
# estimate: "POS" or "neg" # select correlation type
# correlation = "RAW"or "SIGN" or "PARTIAL"
# if correlation = PARTIAL, requires function "pcor.R"
# if correlation = RAW or SIGN, requires funtion "flattenCorrMatrix" + load "Himsc"

Network_metrics <- function(np,mws,data,estimate,correlation) { ####
  nn = c(1:(np-(mws-1))) 
  Subset <- list () 
  for (i in nn){ 
    order_1 <- c(0:(mws-1))+i
    Subset[length(Subset)+1] <- list(order_1)
  }
  
  edges.list<-list()
  for (i in 1:length(Subset)){   
    if (correlation == "RAW") {
      temp_corr <- rcorr(as.matrix(data[Subset[[i]],],type="pearson"))
      temp_corr<-flattenCorrMatrix(temp_corr$r, temp_corr$P)
      ifelse (estimate=="POS",temp_corr$cor[temp_corr$cor<0]<-0,temp_corr$cor[temp_corr$cor>0]<-0)
              #temp_corr <-temp_corr[(temp_corr$cor>0),],
              #temp_corr <-temp_corr[(temp_corr$cor<0),])
      corr_list <-temp_corr
    } else if  (correlation == "SIGN") {  #significant correlations
      temp_corr <- rcorr(as.matrix(data[Subset[[i]],],type="pearson"))
      temp_corr<-flattenCorrMatrix(temp_corr$r, temp_corr$P)
      if (estimate=="POS") { 
        temp_corr$cor[temp_corr$cor<0]=0###keep the SDGs that don't have linkages,just use 0!!!
        temp_corr$cor[temp_corr$p>=0.05]=0
        #temp_corr <-temp_corr[(temp_corr$cor>0),]###exclude the the SDGs that don't have linkages!!!
        #temp_corr <-temp_corr[(temp_corr$p<=0.05),]
      } else { 
        temp_corr$cor[temp_corr$cor>0]=0###keep the SDGs that don't have linkages,just use 0!!!
        temp_corr$cor[temp_corr$p>=0.05]=0
        #temp_corr <-temp_corr[(temp_corr$cor<0),]###exclude the the SDGs that don't have linkages!!!
        #temp_corr <-temp_corr[(temp_corr$p<=0.05),]
        }
      corr_list <- temp_corr
    } 
    colnames(corr_list)<- c("from","to","estimate","p.value")
    # convert my matrix into an object readble by igraph
    edges<-corr_list[,c("from","to","estimate")]
    colnames(edges)<- c("from","to","weight")
    edges.list[length (edges.list)+1] <- list(edges)
    print (paste(i, "out of",length(Subset)))
  } # if is finished    
  
  # add window block
  for( w in seq_along(edges.list)){                
    edges.list[[w]]$window_block <- rep(w,nrow(edges.list[[w]]))
  }
  
  edges.list <- Reduce(rbind, edges.list)#将多个数组变为一个矩阵，window_block为一组  
  
  Select.Net.metrics <-list()
  Select.Net.metrics_final<-list() 
  Select.Node.metrics <-list() 
  Select.Net.matrix<-list()
  Select.Net.matrix_final <-list()
  Select.Net <-list()
  
  
  
  for (q in nn){ #if a block gives problems, can be excluded (e.g. exclude block 8): nn[-8]
    Netdata <- graph_from_data_frame(d=subset(edges.list,window_block == q), directed=F)
    
    # save the net object as matrix for checking
    Select.Net.matrix<- as_adjacency_matrix(Netdata, type="both", attr="weight",sparse=FALSE)
    Net<-graph_from_adjacency_matrix(Select.Net.matrix,mode="undirected",weighted=TRUE,diag=FALSE)
    Select.Net.matrix_final[length (Select.Net.matrix_final)+1] <- list(Select.Net.matrix)
    
    # save the net object for plotting
    Select.Net[length (Select.Net)+1] <- list(Net) 
    
    ## METRICS: use absolute weights !
    degree<-  degree(Net, mode="all")  # degree: number of links of a node 
    density <-edge_density(Net, loops=F)   # density = connectance: proportion of present edges from all possible edges in the network
    weighted.density <- sum(abs(E(Net)$weight)) / ((vcount(Net)*(vcount(Net)-1))/2) # own adaptation inspired by StackOverflow
    modularity<-modularity(Net,membership(cluster_walktrap(Net)), weights=abs(E(Net)$weight))#(values>0.4 suggest that the network has a modular structure; Newman,2006).
    # evenness
    m<-Select.Net.matrix_final[[q]]
    df<-data.frame(row=rownames(m)[row(m)[upper.tri(m)]], 
                   col=colnames(m)[col(m)[upper.tri(m)]], 
                   corr=m[upper.tri(m)])
    df2 <- droplevels (df [!(df$corr==0),])
    
    H <- vegan::diversity(abs(df2 [,"corr"]))# with absolute values
    S <- dim (df2)[1]
    evenness <- H/log(S)
    
    # create the data frame for NETWORK LEVEL metrics: 
    Net.metrics <- c(density,weighted.density,modularity, evenness )
    indicators <- c("connectance","weighted.density","modularity", "evenness")
    names (Net.metrics)<- indicators
    Select.Net.metrics[length(Select.Net.metrics)+1] <- list(Net.metrics)
    
    # create the data frame for NODE LEVEL metrics: 
    temp.Node.metrics <- list(as.vector(degree))
    vertex <-  names (degree)                                           
    Node.metrics<- lapply(temp.Node.metrics, setNames, vertex)         
    nodes <- names (degree)                                                                          
    Node.metrics[length(Node.metrics)+1] <- list(nodes)                                                            
    Node.metrics[length(Node.metrics)+1] <- list(rep (q, lengths(Node.metrics)[1])) #info window_block                                      
    names (Node.metrics) <- c("degree","nodes","window_block") 
    Select.Node.metrics[length(Select.Node.metrics)+1] <- list(Node.metrics)
    
    edges<-NULL
    Net<-NULL
    Net.metrics<- NULL
    Node.metrics<- NULL
    Select.Net.matrix<-NULL
  }
  Select.Net.metrics_final <- Reduce(rbind, Select.Net.metrics)  
  Select.Net.metrics_final <- as.data.frame(Select.Net.metrics_final)
  Select.Net.metrics_final$window_block <- rep (nn) #if a block was excluded, adapt this (e.g. block 8 excluded): nn[-8]
  rownames (Select.Net.metrics_final) <-NULL  
  
  Select.Node.metrics_final <- rbindlist(Select.Node.metrics, fill=TRUE,use.names=TRUE)            
  Select.Node.metrics_final <- as.data.frame(Select.Node.metrics_final)
  #reorder columns
  Select.Node.metrics_final<-Select.Node.metrics_final[,c("window_block","nodes","degree")]
  Select.Node.metrics_final$nodes <- as.factor(Select.Node.metrics_final$nodes)
  
  output <- list (Select.Net.metrics_final,
                  Select.Node.metrics_final,
                  Select.Net.matrix_final,
                  Select.Net,
                  edges.list)
  names(output) <- c("Select.Net.metrics_final",
                     "Select.Node.metrics_final",
                     "Select.Net.matrix_final",
                     "Select.Net",
                     "edges.list")
  return (output)
} 
#calculate the metrics of the SDG network
#synergy network
metrics <- Network_metrics (np=166, mws=60,data=data, estimate="POS",correlation="SIGN")
Select.Net.metrics_pos <- metrics$Select.Net.metrics_final
Select.Nodes_pos <- metrics$Select.Node.metrics_final
Select.Net.matrix_pos <- metrics$Select.Net.matrix_final
Select.pos.NET <- metrics$Select.Net
Select.pos.edges <- metrics$edges.list

#Create variable "SDG Index" ----
#define parameters
np=166
mws=60
nn = c(1:(np-(mws-1))) 
# create the subsets
Subset <- list () 
SDG_values <- list ()
meanSDG <- NULL

for (i in 1:max(nn)){    
  order_1 <- c(0:(mws-1))+i #mws of 60 plots
  Subset[length(Subset)+1] <- list(order_1)
}
# calculate mean SDG for each subset
for (i in 1:max(nn)){    
  meanSDG <- mean(data_in[Subset[[i]],"SDG.Index"]) 
  SDG_values[length(SDG_values)+1] <- list(meanSDG)
}
SDG_table <- Reduce(rbind, SDG_values)
SDG_table<-as.data.frame(SDG_table)
SDG_table$windows_block<-c(1:length(nn)) 
colnames(SDG_table) <-c("mean_SDG","window_block")
rownames(SDG_table)<-NULL
SDG_pos<- merge(Select.Net.metrics_pos,SDG_table,by="window_block")

#tradeoff network
metrics <- Network_metrics (np=166, mws=60,data=data, estimate="neg",correlation="SIGN")
Select.Net.metrics_neg <- metrics$Select.Net.metrics_final
Select.Nodes_neg <- metrics$Select.Node.metrics_final
Select.Net.matrix_neg <- metrics$Select.Net.matrix_final
Select.neg.NET <- metrics$Select.Net
Select.neg.edges <- metrics$edges.list
SDG_neg<- merge(Select.Net.metrics_neg,SDG_table,by="window_block")

#MODELS ====
#For synergy networks ----
#add SDG
Select.Net.metrics_pos<- merge(Select.Net.metrics_pos,SDG_table,by="window_block")


## SELECTED GAMs MODELS: best fit with reasonable ecology behind - ie. only one up/down curve (see example of how to check the models below)
library(mgcv)
cog <- gam(connectance  ~ s(mean_SDG,k=6),data=Select.Net.metrics_pos)
wdg <- gam(weighted.density  ~ s(mean_SDG,k=6),data=Select.Net.metrics_pos) 
evg <- gam(evenness ~ s(mean_SDG,k=4),data=Select.Net.metrics_pos)
mog <- gam(modularity ~ s(mean_SDG,k=5),data=Select.Net.metrics_pos)

# Example for how to check the models 
summary(wdg)
plot.gam(wdg)
par(mfrow=c(2,2))
gam.check(wdg)
AIC(wdg)  

## including example of comparing GAMs with lm, and Polynomial
wdPol1 <- lm(weighted.density ~ mean_SDG,data=subset(Select.Net.metrics_pos))
summary(wdPol1)
wdPol2 <- lm(weighted.density ~ poly(mean_SDG,2),data=subset(Select.Net.metrics_pos))
summary(wdPol2) 
wdPol3 <- lm(weighted.density ~ poly(mean_SDG,3),data=subset(Select.Net.metrics_pos))
summary(wdPol3) 

anova(wdPol1,wdPol2,wdPol3) 
AIC(wdPol1,wdPol2,wdPol3) #m1

anova(wdPol1,wdg)
AIC(wdPol1,wdg) #gam 

#for trade-off networks----
#add SDG
Select.Net.metrics_neg<- merge(Select.Net.metrics_neg,SDG_table,by="window_block")

## SELECTED GAMs MODELS: best fit with reasonable ecology behind - ie. only one up/down curve (see example of how to check the models below)
library(mgcv)
cog_neg <- gam(connectance  ~ s(mean_SDG,k=6),data=Select.Net.metrics_neg)
wdg_neg <- gam(weighted.density  ~ s(mean_SDG,k=6),data=Select.Net.metrics_neg) 
evg_neg <- gam(evenness ~ s(mean_SDG,k=4),data=Select.Net.metrics_neg)
mog_neg <- gam(modularity ~ s(mean_SDG,k=5),data=Select.Net.metrics_neg)

# to check the models 
summary(mog_neg)
plot.gam(mog_neg)
par(mfrow=c(2,2))
gam.check(mog_neg)

library (gratia)
library(ggplot2)
library(mgcViz)

# prepare data and check significance
summary(wdg)
cog_conf <-confint(cog, parm = "mean_SDG", partial_match=TRUE)
cog_neg_conf <-confint(cog_neg, parm = "mean_SDG", type = "confidence",partial_match=TRUE)
wdg_conf <-confint(wdg, parm = "mean_SDG", type = "confidence",partial_match=TRUE)
wdg_neg_conf <-confint(wdg_neg, parm = "mean_SDG", type = "confidence",partial_match=TRUE)
mog_conf <-confint(mog, parm = "mean_SDG", type = "confidence",partial_match=TRUE)
mog_neg_conf <-confint(mog_neg, parm = "mean_SDG", type = "confidence",partial_match=TRUE) # N.S.
evg_conf <-confint(evg, parm = "mean_SDG", type = "confidence",partial_match=TRUE)
evg_neg_conf <-confint(evg_neg, parm = "mean_SDG", type = "confidence",partial_match=TRUE)


# PLOT THE FIGURE
plot1 <- ggplot( ) +
  labs(y ="Connectivity (scaled)",x="SDG scores") + 
  geom_line(data=cog_conf, aes(x = mean_SDG,y = est), size = 1,colour = "blue") +
  geom_ribbon(data = cog_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="blue",alpha = .15)+ 
  theme_classic()  +
  geom_line(data=cog_neg_conf, aes(x = mean_SDG,y = est), size = 1,colour = "red") +
  geom_ribbon(data = cog_neg_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="red",alpha = .15)

plot2 <- ggplot( ) +
  labs(y ="Weighted density (scaled)",x="SDG scores") + 
  geom_line(data=wdg_conf, aes(x = mean_SDG,y = est), size = 1,colour = "blue") +
  geom_ribbon(data = wdg_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="blue",alpha = .15)+ 
  theme_classic()  +
  geom_line(data=wdg_neg_conf, aes(x = mean_SDG,y = est), size = 1,colour = "red") +
  geom_ribbon(data = wdg_neg_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="red",alpha = .15)

plot3 <- ggplot( ) +
  labs(y ="Modularity (scaled)",x="SDG scores") + 
  geom_line(data=mog_conf, aes(x = mean_SDG,y = est), size = 1,colour = "blue") +
  geom_ribbon(data = mog_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="blue",alpha = .15)+ 
  theme_classic()  +
  geom_line(data=mog_neg_conf, aes(x = mean_SDG,y = est), size = 1,colour = "red") +
  geom_ribbon(data = mog_neg_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="red",alpha = .15)

plot4 <- ggplot( ) +
  labs(y ="Evenness (scaled)",x="SDG scores") + 
  geom_line(data=evg_conf, aes(x = mean_SDG,y = est), size = 1,colour = "blue") +
  geom_ribbon(data = evg_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="blue",alpha = .15)+ 
  theme_classic()  +
  geom_line(data=evg_neg_conf, aes(x = mean_SDG,y = est), size = 1,colour = "red") +
  geom_ribbon(data = evg_neg_conf, aes(x = mean_SDG,y = NULL, ymin = lower, ymax = upper),fill="red",alpha = .15)

# Multiple graphs on the same page
gridPrint(grobs = list(plot1,plot2,plot3,plot4), ncol = 2)


#node figure
library(ggplot2)
node_pos<-merge(Select.Nodes_pos,SDG_table,by="window_block")
node_pos=node_pos[,2:4]
pal<-colorRampPalette(c('#EA1B2D','#D19E28','#269A45','#C11E31','#EF4129','#00ADD8','#FBB611','#8E1737','#F26D22','#DF1382','#F99D22','#CC8B27','#47773D','#007CBA','#3EAE48','#01548A','#1A3666'))
ggplot(node_pos,aes(x=mean_SDG,y=degree,group=nodes))+geom_smooth(aes(colour=nodes), se= FALSE)+
  scale_colour_manual(values=pal(17))+guides(color=guide_legend(title="SDG"))+labs(x = "SDG Index", y="Degree")+
  theme_bw() +
  theme(panel.border = element_rect(colour = "black"),legend.text=element_text(size=10),legend.title=element_text(size=12),strip.text.y = element_blank())

node_neg<-merge(Select.Nodes_neg,SDG_table,by="window_block")
node_neg=node_neg[,2:4]
pal<-colorRampPalette(c('#EA1B2D','#D19E28','#269A45','#C11E31','#EF4129','#00ADD8','#FBB611','#8E1737','#F26D22','#DF1382','#F99D22','#CC8B27','#47773D','#007CBA','#3EAE48','#01548A','#1A3666'))
ggplot(node_neg,aes(x=mean_SDG,y=degree,group=nodes))+geom_smooth(aes(colour=nodes), se= FALSE)+
  scale_colour_manual(values=pal(17))+guides(color=guide_legend(title="SDG"))+labs(x = "SDG Index", y="Degree")+
  theme_bw() +
  theme(panel.border = element_rect(colour = "black"),legend.text=element_text(size=10),legend.title=element_text(size=12),strip.text.y = element_blank())

#node weighted degree
mean_corr <- NULL
mean_corr_all<- list()
mean_corr_all2<- list()

for (i in 1:length(nn)){ 
  for (j in 1: ncol(Select.Net.matrix_pos[[i]])){ 
    mean_corr <- sum(Select.Net.matrix_pos [[i]][,j])/(ncol(Select.Net.matrix_pos[[i]])-1)
    mean_corr <- as.data.frame(mean_corr)
    mean_corr$node_name <- names(Select.Net.matrix_pos[[i]][,j])[j]
    mean_corr$window_block<- i 
    colnames(mean_corr)<-c("mean_corr","node_name","window_block")
    mean_corr_all[length(mean_corr_all)+1] <- list(mean_corr)
    
  }
  mean_corr_all <- Reduce(rbind, mean_corr_all)
  mean_corr_all <- as.data.frame(mean_corr_all)
  rownames (mean_corr_all) <- NULL
  mean_corr_all2[length(mean_corr_all2)+1] <- list(mean_corr_all)
  mean_corr_all<- list()
}
mean_corr_all2<- Reduce(rbind, mean_corr_all2)
mean_corr_all2 <- as.data.frame(mean_corr_all2)

# add mean corr as a weight
Selected.Nodes_pos<- merge(Select.Nodes_pos,mean_corr_all2,by.x=c("nodes","window_block"),by.y=c("node_name","window_block"))
# D is degree_2w
Selected.Nodes_pos$degree_2w <-Selected.Nodes_pos$degree*Selected.Nodes_pos$mean_corr
library(ggplot2)
node_pos<-merge(Selected.Nodes_pos,SDG_table,by="window_block")
pal<-colorRampPalette(c('#EA1B2D','#D19E28','#269A45','#C11E31','#EF4129','#00ADD8','#FBB611','#8E1737','#F26D22','#DF1382','#F99D22','#CC8B27','#47773D','#007CBA','#3EAE48','#01548A','#1A3666'))
ggplot(node_pos,aes(x=mean_SDG,y=degree_2w,group=nodes))+geom_smooth(aes(colour=nodes), se= FALSE)+
  scale_colour_manual(values=pal(17))+guides(color=guide_legend(title="SDG"))+labs(x = "SDG Index", y="Weighted degree")+
  theme_bw() +
  theme(panel.border = element_rect(colour = "black"),legend.text=element_text(size=10),legend.title=element_text(size=12),strip.text.y = element_blank())

#node weighted degree for tradeoff
mean_corr <- NULL
mean_corr_all<- list()
mean_corr_all2<- list()

for (i in 1:length(nn)){ 
  for (j in 1: ncol(Select.Net.matrix_neg[[i]])){ 
    mean_corr <- sum(Select.Net.matrix_neg [[i]][,j])/(ncol(Select.Net.matrix_neg[[i]])-1)
    mean_corr <- as.data.frame(mean_corr)
    mean_corr$node_name <- names(Select.Net.matrix_neg[[i]][,j])[j]
    mean_corr$window_block<- i 
    colnames(mean_corr)<-c("mean_corr","node_name","window_block")
    mean_corr_all[length(mean_corr_all)+1] <- list(mean_corr)
    
  }
  mean_corr_all <- Reduce(rbind, mean_corr_all)
  mean_corr_all <- as.data.frame(mean_corr_all)
  rownames (mean_corr_all) <- NULL
  mean_corr_all2[length(mean_corr_all2)+1] <- list(mean_corr_all)
  mean_corr_all<- list()
}
mean_corr_all2<- Reduce(rbind, mean_corr_all2)
mean_corr_all2 <- as.data.frame(mean_corr_all2)
mean_corr_all2$mean_corr=abs(mean_corr_all2$mean_corr)#tradeoff

# add mean corr as a weight
Selected.Nodes_neg<- merge(Select.Nodes_neg,mean_corr_all2,by.x=c("nodes","window_block"),by.y=c("node_name","window_block"))
# D is degree_2w
Selected.Nodes_neg$degree_2w <-Selected.Nodes_neg$degree*Selected.Nodes_neg$mean_corr
library(ggplot2)
node_neg<-merge(Selected.Nodes_neg,SDG_table,by="window_block")
pal<-colorRampPalette(c('#EA1B2D','#D19E28','#269A45','#C11E31','#EF4129','#00ADD8','#FBB611','#8E1737','#F26D22','#DF1382','#F99D22','#CC8B27','#47773D','#007CBA','#3EAE48','#01548A','#1A3666'))
ggplot(node_neg,aes(x=mean_SDG,y=degree_2w,group=nodes))+geom_smooth(aes(colour=nodes), se= FALSE)+
  scale_colour_manual(values=pal(17))+guides(color=guide_legend(title="SDG"))+labs(x = "SDG Index", y="Weighted degree")+
  theme_bw() +
  theme(panel.border = element_rect(colour = "black"),legend.text=element_text(size=10),legend.title=element_text(size=12),strip.text.y = element_blank())


# Modules ====
# Prepare data ----
library(igraph)
library(reshape2)
# define the parameters
np = 166 # number of plots
mws=60 # moving window size
nn = c(1:(np-(mws-1)))  # network number
N = length (V(Select.pos.NET[[min(nn)]])) # number of nodes - igraph object from network analysis

###
par(mfrow=c(3,4))
netnum=107
SDG_values[netnum]
communities<-cluster_louvain(Select.pos.NET[[netnum]], weights = E(Select.pos.NET[[netnum]])$weight)
modules <- communities$membership 
eb=communities
igraph=Select.pos.NET[[netnum]]
set.seed(123)
plot(main=modularity(eb),eb,igraph,vertex.frame.color=NA,edge.lty=1,margin=c(0,0,0,0))
#tradeoff module
E(Select.neg.NET[[netnum]])$weight=abs(E(Select.neg.NET[[netnum]])$weight)
communities<-cluster_louvain(Select.neg.NET[[netnum]], weights = E(Select.neg.NET[[netnum]])$weight)
modules <- communities$membership 
eb=communities
igraph=Select.neg.NET[[netnum]]
set.seed(2)
plot(main=modularity(eb),eb,igraph,vertex.frame.color=NA,edge.lty=1,margin=c(0,0,0,0))

# get modules using the "cluster_louvain" algorithm (this gives a more balanced number of modules than "walktrap")
communities_low<-cluster_louvain(Select.pos.NET[[min(nn)]], weights = E(Select.pos.NET[[min(nn)]])$weight)
modules_low <- communities_low$membership 
communities_high<-cluster_louvain(Select.pos.NET[[max(nn)]], weights = E(Select.pos.NET[[max(nn)]])$weight)
modules_high <- communities_high$membership 

##just try to plot the cluster
eb=communities_high
igraph=Select.pos.NET[[max(nn)]]
set.seed(2)
plot(main=modularity(eb),eb,igraph,vertex.frame.color=NA,edge.lty=1,margin=c(0,0,0,0))

# tradeoff module
np = 166 # number of plots
mws=60 # moving window size
nn = c(1:(np-(mws-1)))  # network number
N = length (V(Select.neg.NET[[min(nn)]])) # number of nodes - igraph object from network analysis

# get modules using the "cluster_louvain" algorithm (this gives a more balanced number of modules than "walktrap")
communities_low<-cluster_louvain(Select.neg.NET[[min(nn)]], weights = abs(E(Select.neg.NET[[min(nn)]])$weight))
modules_low <- communities_low$membership 
communities_high<-cluster_louvain(Select.neg.NET[[max(nn)]], weights = abs(E(Select.neg.NET[[max(nn)]])$weight))
modules_high <- communities_high$membership 

##just try to plot the cluster
eb=communities_high
igraph=Select.neg.NET[[max(nn)]]
set.seed(2)
plot(main=modularity(eb),eb,igraph,vertex.frame.color=NA,edge.lty=1,margin=c(0,0,0,0))



# create a dataframe 
a <- data.frame (communities_low$names,modules_low)
a <- a[order(a$communities_low),]
b <- data.frame (communities_high$names,modules_high)
b <- b[order(b$communities_high),]
modules<- merge(a,b,by.x=c("communities_low.names"),by.y=c("communities_high.names"))#,all=TRUE merge all
colnames (modules) <- c("nodes","modules_low","modules_high")

modules_long <- reshape2::melt(modules, id="nodes")

#rename variables for the figure
modules_long$variable <-with (modules_long, ifelse (variable  =="modules_low","Low SDG Index", "High SDG Index"))
modules_long$variable <- factor (modules_long$variable, levels=c ("Low SDG Index", "High SDG Index"))

# order the labels by SDG to use the annotate function
modules_long_low <- subset(modules_long,variable=="Low SDG Index")
modules_long_high <- subset(modules_long,variable=="High SDG Index")
modules_long_high <- cbind(modules_long_low,modules_long_high)

#order 1潞 by value + 2潞 by variable name at low SDG
modules_long_high<-modules_long_high[order(modules_long_high$value),]
# Now, reorder LOW levels for the figure
modules_long_low <- modules_long_low[order(modules_long_low$value),]

# Figure 3 ----
library("ggforce")
library (gtable)
library (mgcViz) 
library(tidyr)

# add parameters required to plot the figure
modules_long <- modules_long [order (modules_long$variable,modules_long$nodes),]
modules_long$id <- c(rep(c(1:14),2)) # different number for each node
modules_long$idd <- 1 # fix number = 1
modules_long$value <- as.factor (modules_long$value ) #it needs to be a factor!
# calculate the parameters to annotate the text in the figure
# default: ((1, [A],  ([A]+2.5), ([A]+2.5+[B]-0.5),   ([A]+2.5+[B]-0.5+2), ([A]+2.5+[B]-0.5+2+[C]-0.5)) - 0.5   
rev (table(modules_long$variable,modules_long$value)[1,]) # LOW SDG (0 9 6 15)
# c(1,9,     11.5,17,   19,33.5) -0.5 
# c(0.5:8.5, 11.0:16.5, 18.5:33) 
rev (table(modules_long$variable,modules_long$value)[2,])  # high SDG: 8 9 5 8  
# c(1,8,     10.5,19,   21,25.5,  27.5,35) -0.5 # info                              
# c(0.5:7.5, 10.0:18.5, 20.5:25.0, 27.0:34.5)  # this one to annotate

plotG_mods<- ggplot(modules_long, aes(nodes, id = id, value = idd, split = value)) +
  geom_parallel_sets(aes(fill =nodes),alpha = 0.3, axis.width = 0.1) + 
  geom_parallel_sets_axes(axis.width = 0.1 ,fill="white",linetype=1,color="black") + 
  geom_parallel_sets_labels(angle = 0, size = 3,axis.width = 0.1,colour = "white")+ 
  theme_classic () +
  theme(axis.text.y = element_blank(),axis.ticks.y=element_blank(),axis.line.y=element_blank(),
        axis.ticks.x=element_blank(),axis.line.x=element_blank())+ 
  annotate("text", x=0.9 ,y=c(0.5:8.5, 11.0:16.5, 18.5:33) , 
           label=rev(modules_long_low$nodes) ,hjust = 1,size=3, fontface= 2) + #low SDG
  annotate("text", x=2.1 ,y=c(0.5:7.5, 10.0:18.5, 20.5:25.0, 27.0:34.5), 
           label=rev(modules_long_high$nodes) ,hjust = 0,size=3, fontface= 2) + # high SDG
  theme(legend.position = "none", 
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        plot.title = element_text(hjust = 0.5))+ 
  ggtitle("Grasslands")+  
  scale_fill_manual(values=c(rep("grey30",15),rep("grey50",6),rep("grey80",9)))+ # number of items in each low SDG module
  scale_y_continuous(expand = c(0, 0.3))+ 
  scale_x_discrete(expand = expand_scale(add = c(0.7, 0.7))) 

#Net work figure
np=166
mws=60
nn = c(1:(np-(mws-1))) 
Subset <- list () 
for (i in nn){ 
  order_1 <- c(0:(mws-1))+i
  Subset[length(Subset)+1] <- list(order_1)
}

i=65
temp_corr <- rcorr(as.matrix(data[Subset[[i]],],type="pearson"))
temp_corr<-flattenCorrMatrix(temp_corr$r, temp_corr$P)
corr_list <-temp_corr
colnames(corr_list)<- c("from","to","estimate","p.value")
edges<-corr_list[,c("from","to","estimate")]
pvalue<-corr_list[,c("from","to","p.value")]
Net <- graph_from_data_frame(edges, directed=F)
pnet<- graph_from_data_frame(pvalue, directed=F)
pcor.r<- as_adjacency_matrix(Net, type="both", attr="estimate",sparse=FALSE) 
pcor.p<- as_adjacency_matrix(pnet, type="both", attr="p.value",sparse=FALSE) 
#显著连接标准
pcor.r[pcor.p>0.05] = 0
pcor.r[pcor.r>0] = 0
igraph = graph_from_adjacency_matrix(pcor.r,mode="undirected",weighted=TRUE,diag=FALSE)
igraph
igraph.weight = E(igraph)$weight
# 做图前去掉igraph的weight权重，因为做图时某些layout会受到其影响
E(igraph)$weight = NA
#按相关类型设置边颜色
# 如果构建网络时，weighted=NULL,此步骤不能统计
num_pos<-sum(igraph.weight>0)# number of postive correlation
num_pos
num_neg<-sum(igraph.weight<0)# number of negative correlation
num_neg
# set edge color，postive correlation 设定为blue, negative correlation设定为red
E.color = igraph.weight
E.color = ifelse(E.color>0, "blue",ifelse(E.color<0, "red","grey"))
E(igraph)$color = as.character(E.color)
#按相关性设置边宽度
# 可以设定edge的宽 度set edge width，例如将相关系数与edge width关联
E(igraph)$width = abs(igraph.weight)*6
deg<-degree(igraph)
V(igraph)$size = (deg)*2+2
#设置点的颜色和大小属性
igraph.col = c('#EA1B2D','#D19E28','#269A45','#C11E31','#EF4129','#00ADD8','#FBB611','#8E1737','#F26D22','#DF1382','#F99D22','#CC8B27','#47773D','#007CBA','#3EAE48','#01548A','#1A3666') # 直接修改levles可以连值全部对应替换
V(igraph)$color = as.character(igraph.col)
set.seed(123)
plot(igraph,layout=layout_in_circle,vertex.frame.color=NA,edge.lty=1,margin=c(0,0,0,0))
