import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt
import numpy as np

output_figs = []
stats = pd.DataFrame()

print("Reading mapping stats from STAR output...")
for file in snakemake.input:
    sample = file.split('/')[-1].replace('Log.final.out', '')
    stats = pd.concat([stats, pd.read_csv(file, sep = '\t', names = ['name', sample])[4:].set_index('name')], axis = 1)
print("Reading complete!")
stats.index = stats.index.str.replace('|','', regex = False).str.strip()
stats = stats.transpose()
stats['rep'] = [i[0] for i in list(stats.index.str.split('_', expand = True))]
stats['tissue'] = [i[1] for i in list(stats.index.str.split('_', expand = True))]
stats = stats.reset_index().drop('index', axis =1).iloc[:,list(range(-2,32))]
print("Plotting...")

fig, ax = plt.subplots(1, 2, figsize = (35,15))
plt.subplots_adjust(wspace=0.05)
map_total = stats[['Uniquely mapped reads number', 'rep', 'tissue']]
map_total.loc[:,'Uniquely mapped reads number'] = map_total['Uniquely mapped reads number'].apply(lambda value: int(value))
sns.heatmap(map_total.pivot(columns = 'rep', values = 'Uniquely mapped reads number', index = 'tissue'), robust = True, cmap = 'viridis', ax = ax[0])
labels = list(map_total.pivot(columns = 'rep', values = 'Uniquely mapped reads number', index = 'tissue').index)
ax[0].yaxis.set(ticks=np.arange(0.5, len(labels)), ticklabels=labels)
ax[0].set_title('Uniquely Mapped Reads', fontsize=20)
map_rate = stats[['Uniquely mapped reads %', 'rep', 'tissue']]
map_rate.loc[:,'Uniquely mapped reads %'] = map_rate['Uniquely mapped reads %'].apply(lambda value: float(value.replace('%','')) / 100)
sns.heatmap(map_rate.pivot(columns = 'rep', values = 'Uniquely mapped reads %', index = 'tissue'), robust = True, cmap = 'viridis', ax = ax[1])
ax[1].yaxis.set()
ax[1].set_title('Unique Mapping Rate', fontsize=20)
fig.text(.8, .05, 'Missing values are indicated by blanks. This means no RNAseq data of this tissue is available from this particular horse', ha='right', fontsize = 15)
output_figs.append(fig)

fig, ax = plt.subplots(1, 2, figsize = (35,15))
plt.subplots_adjust(wspace=0.05)
multi_map_total = stats[['Number of reads mapped to multiple loci', 'rep', 'tissue']]
multi_map_total.loc[:,'Number of reads mapped to multiple loci'] = multi_map_total['Number of reads mapped to multiple loci'].apply(lambda value: int(value))
sns.heatmap(multi_map_total.pivot(columns = 'rep', values = 'Number of reads mapped to multiple loci', index = 'tissue'), robust = True, cmap = 'viridis', ax = ax[0])
labels = list(multi_map_total.pivot(columns = 'rep', values = 'Number of reads mapped to multiple loci', index = 'tissue').index)
ax[0].yaxis.set(ticks=np.arange(0.5, len(labels)), ticklabels=labels)
ax[0].set_title('Multi-mapping Reads', fontsize=20)
multi_map_rate = stats[['% of reads mapped to multiple loci', 'rep', 'tissue']]
multi_map_rate.loc[:,'% of reads mapped to multiple loci'] = multi_map_rate['% of reads mapped to multiple loci'].apply(lambda value: float(value.replace('%','')) / 100)
sns.heatmap(multi_map_rate.pivot(columns = 'rep', values = '% of reads mapped to multiple loci', index = 'tissue'), robust = True, cmap = 'viridis', vmin = 0, ax = ax[1])
ax[1].yaxis.set()
ax[1].set_title('Multi-mapping Rate', fontsize=20)
fig.text(.8, .05, 'Missing values are indicated by blanks. This means no RNAseq data of this tissue is available from this particular horse', ha='right', fontsize = 15)
output_figs.append(fig)

print("Saving to output...")

from matplotlib.backends.backend_pdf import FigureCanvasPdf, PdfPages
with PdfPages(snakemake.output['pdf']) as pages:
    for i in output_figs:
        canvas = FigureCanvasPdf(fig)
        canvas.print_figure(pages)

stats.to_csv(snakemake.output['csv'], index = False)