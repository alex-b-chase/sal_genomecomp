setwd('/Volumes/Bennett_BACKUP/Research/jensen-metabolites/fiji_sal-microscale/genome_comp')

data <- read.table('total.genome.stats.txt', header = T, sep = '\t')

library(splitstackshape)
data2 <- cSplit(data, "Sequence_ID", ".")

library(ggplot2)
require(grid)

fig1 <- ggplot(data2, aes(fill = Sequence_ID_2)) +
  geom_boxplot(aes(x = Sequence_ID_2, y = Genome_length)) +
  geom_hline(yintercept = 5786361, color = "blue", size = 2) +
  geom_text(aes(1, 5786361, label = "SACNS205", vjust = -1), color = "blue") +
  geom_hline(yintercept = 5736866.839, color = "red", linetype = "dashed", size = 2) +
  geom_hline(yintercept = c(5736866.839 + 357080.4834), color = "lightcoral", linetype = "dashed", size = 2) +
  geom_text(aes(1.3, c(5736866.839 + 357080.4834), label = "+1 SD mean SA", vjust = 2), color = "lightcoral") +
  geom_hline(yintercept = c(5736866.839 - 357080.4834), color = "lightcoral", linetype = "dashed", size = 2) +
  geom_text(aes(1.3, c(5736866.839 - 357080.4834), label = "-1 SD mean SA", vjust = -1), color = "lightcoral") +
  theme_bw() +
  theme(legend.title = element_blank())

fig2 <- ggplot(data2, aes(x = Total_Contigs, y = n50, color = Sequence_ID_2, factor = Sequence_ID_1, group = Sequence_ID_2)) +
  geom_point(size = 2) +
  geom_density2d(bins=3) +
  theme_bw() +
  theme(legend.title = element_blank()) +
  scale_y_continuous(labels = scales::comma, limits = c(10000, 600000)) +
  scale_x_continuous(limits = c(0,300))


pdf('genome-assemblers.pdf', height = 8, width = 8)

grid.draw(rbind(ggplotGrob(fig1),
                ggplotGrob(fig2),
                size = "first"))

dev.off()