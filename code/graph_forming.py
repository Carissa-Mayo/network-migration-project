import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature

# --- PROJECTIONS ---
proj = ccrs.Mercator()        # display projection
pc   = ccrs.PlateCarree()     # data lon/lat CRS

# --- GRAPH ---
G = nx.DiGraph()
G.add_edge(1, 2, weight=14)
G.add_edge(1, 3, weight=2)
G.add_edge(1, 4, weight=2)
G.add_edge(1, 5, weight=4)
G.add_edge(1, 6, weight=4)
G.add_edge(1, 8, weight=1)
G.add_edge(2, 1, weight=4)
G.add_edge(2, 3, weight=8)
G.add_edge(2, 4, weight=2)
G.add_edge(2, 5, weight=4)
G.add_edge(2, 6, weight=3)
G.add_edge(3, 1, weight=2)
G.add_edge(3, 4, weight=9)
G.add_edge(3, 7, weight=1)
G.add_edge(4, 1, weight=8)
G.add_edge(4, 2, weight=2)
G.add_edge(4, 3, weight=2)
G.add_edge(4, 7, weight=2)
G.add_edge(4, 9, weight=12)
G.add_edge(5, 1, weight=4)
G.add_edge(5, 2, weight=4)
G.add_edge(5, 8, weight=2)
G.add_edge(6, 1, weight=5)
G.add_edge(6, 2, weight=1)
G.add_edge(6, 9, weight=2)
G.add_edge(7, 1, weight=1)
G.add_edge(7, 4, weight=2)
G.add_edge(8, 5, weight=2)
G.add_edge(9, 1, weight=2)
G.add_edge(9, 4, weight=11)
G.add_edge(9, 6, weight=1)

G.add_node(1, weight=27, loc="Kralendijk")
G.add_node(2, weight=21, loc="Aruba")
G.add_node(3, weight=12, loc="Caribbean Sea")
G.add_node(4, weight=26, loc="East Nicaragua")
G.add_node(5, weight=10, loc="Santa Marta")
G.add_node(6, weight=8,  loc="Santo Domingo")
G.add_node(7, weight=3,  loc="Jamaica")
G.add_node(8, weight=2,  loc="Isla de Margarita")
G.add_node(9, weight=14, loc="Puerto Rico")

# --- POSITIONS in lon/lat ---
lonlat = {
    1: (-67.668864, 12.162359),  # East of Curacao (Kralendijk)
    2: (-70.448604, 12.222182),  # North Aruba
    3: (-75.296125, 15.024057),  # Caribbean Sea
    4: (-82.970083, 14.567726),  # East Nicaragua
    5: (-74.286615, 11.064685),  # Northern Colombia (Santa Marta)
    6: (-70.526640, 18.016697),  # Dominican Republic (Santo Domingo)
    7: (-76.567509, 18.009788),  # East Jamaica
    8: (-64.373907, 11.060126),  # East Isla de Margarita
    9: (-65.610550, 18.223654),  # East Puerto Rico
}

# Project lon/lat -> Mercator XY for NetworkX
def project_xy(lon, lat):
    x, y = proj.transform_point(lon, lat, pc)[:2]
    return (x, y)

pos = {n: project_xy(*lonlat[n]) for n in lonlat}

# Node sizes
node_sizes = [G.nodes[n].get('weight', 1) * 20 for n in G.nodes()]

# --- Figure helper: make a map axis with the same extent you used in Basemap ---
def make_map_fig():
    fig, ax = plt.subplots(figsize=(15, 8), subplot_kw=dict(projection=proj))
    ax.set_extent([-90, -60, 5, 25], crs=pc)
    ax.add_feature(cfeature.LAND, facecolor='lightgray', edgecolor='none')
    ax.add_feature(cfeature.OCEAN)
    ax.add_feature(cfeature.COASTLINE, linewidth=0.7)
    ax.gridlines(draw_labels=True, linewidth=0.3, color='gray', alpha=0.5)
    return fig, ax

# ----- FIGURE 1: quick network over the map -----
fig, ax = make_map_fig()
nx.draw_networkx(
    G, pos,
    node_size=node_sizes,
    node_color='green',
    alpha=0.75,
    edge_color='y',
    connectionstyle='arc3,rad=0.1',
    with_labels=True,
    font_size=9,
    ax=ax
)
plt.tight_layout()
plt.show()

# ----- EDGE PARTITION: straight vs curved -----
edge_set = set(G.edges())
curved_edges = [(u, v) for (u, v) in G.edges() if (v, u) in edge_set]
straight_edges = list(edge_set.difference(curved_edges))

# label offsets (slightly above nodes) in projected units
pos_attrs = {node: (pos[node][0], pos[node][1] + 100000) for node in pos}
custom_labels = nx.get_node_attributes(G, 'loc')

# ----- FIGURE 2: arrows sized by weight -----
fig, ax = make_map_fig()
nx.draw_networkx_nodes(G, pos, node_size=node_sizes, node_color='g', alpha=0.75, ax=ax)
nx.draw_networkx_labels(G, pos, ax=ax, font_size=9)

for (u, v, d) in G.edges(data=True):
    w = d.get('weight', 1)
    nx.draw_networkx_edges(
        G, pos, edgelist=[(u, v)],
        arrowsize=2 * w, edge_color='y',
        connectionstyle='arc3,rad=0.1', ax=ax
    )

nx.draw_networkx_edges(G, pos, edgelist=straight_edges, edge_color='red', ax=ax)

nx.draw_networkx_labels(G, pos_attrs, labels=custom_labels,
                        font_color='white', font_weight='bold', ax=ax)

plt.tight_layout()
plt.savefig('mapPlotWithColors.png', dpi=200)
plt.show()

# ----- FIGURE 3: weighted widths (curved vs straight) -----
edge_weights = nx.get_edge_attributes(G, 'weight')
s = [edge_weights[e] / 4.0 for e in straight_edges]
c = [edge_weights[e] / 4.0 for e in curved_edges]

fig, ax = make_map_fig()
nx.draw_networkx_nodes(G, pos, node_size=node_sizes, node_color='y', ax=ax)
nx.draw_networkx_labels(G, pos, ax=ax, font_size=9)

if straight_edges:
    nx.draw_networkx_edges(G, pos, ax=ax, edgelist=straight_edges,
                           width=s, edge_color='white')
arc_rad = 0.25
if curved_edges:
    nx.draw_networkx_edges(G, pos, ax=ax, edgelist=curved_edges,
                           arrowsize=25, connectionstyle=f'arc3,rad={arc_rad}',
                           edge_color='white', width=c)

nx.draw_networkx_labels(G, pos_attrs, labels=custom_labels,
                        font_color='white', font_weight='bold', ax=ax)

plt.tight_layout()
plt.savefig('mapPlotWithArrowsWeight.png', dpi=200)
plt.show()

# ----- BASIC STATS (largest weakly connected component) -----
print(G.nodes.data())
print(G.edges.data())

fig, ax = plt.subplots(figsize=(15, 8))
nx.draw_networkx(
    G, pos=nx.circular_layout(G),
    node_size=node_sizes, node_color='red',
    arrowsize=20, connectionstyle='arc3,rad=0.1', ax=ax
)
plt.tight_layout()
plt.show()

degrees = dict(G.degree())
kis = list(degrees.values())
kmax = max(kis) if kis else 0
kstd = np.std(kis) if kis else float('nan')
print("degrees:", degrees)
print("kmax:", kmax)
print("kstd:", kstd)

if nx.number_weakly_connected_components(G) > 0:
    giant_nodes = max(nx.weakly_connected_components(G), key=len)
    H = G.subgraph(giant_nodes).to_undirected()
    if nx.is_connected(H):
        diameter = nx.diameter(H)
        ellmean = nx.average_shortest_path_length(H)
        print("diameter:", diameter)
        print("avg shortest path length:", ellmean)
    else:
        print("Largest subgraph not connected; skipping diameter/ASPL.")
else:
    print("Graph has no nodes; skipping metrics.")

# ----- CCDF helpers -----
def plot_CCDF(kis):
    if not kis:
        return
    kmax = max(kis)
    counts, bins = np.histogram(kis, bins=[i for i in range(kmax + 2)], density=True)
    cumcounts = np.cumsum(counts)
    cumcounts = np.insert(cumcounts, 0, 0)
    plt.figure()
    plt.loglog(bins[1:-1], 1 - cumcounts[1:-1], 'rs', alpha=0.5)
    plt.xlabel('Degree, k'); plt.ylabel('Pr(K>=k)'); plt.title('CCDF (log-log)')
    plt.tight_layout(); plt.show()

def plot_2CCDF(kins, kouts):
    if not kins or not kouts:
        return
    kin_max  = max(kins); kout_max = max(kouts)
    icounts, ibins = np.histogram(kins,  bins=[i for i in range(kin_max  + 2)], density=True)
    ocounts, obins = np.histogram(kouts, bins=[i for i in range(kout_max + 2)], density=True)
    ibcum = np.cumsum(icounts); ibcum = np.insert(ibcum, 0, 0)
    obcum = np.cumsum(ocounts); obcum = np.insert(obcum, 0, 0)
    plt.figure()
    plt.loglog(obins[1:-1], 1 - obcum[1:-1], 'bo', alpha=0.5, label='out-degree')
    plt.loglog(ibins[1:-1], 1 - ibcum[1:-1], 'rs', alpha=0.5, label='in-degree')
    plt.title('CCDF, in- and out-degrees (log-log)')
    plt.xlabel('Degree, k'); plt.ylabel('Pr(K>=k)'); plt.legend(loc='upper right')
    plt.tight_layout(); plt.show()

kins  = [k for _, k in G.in_degree()]
kouts = [k for _, k in G.out_degree()]
plot_CCDF(kis)
plot_2CCDF(kins, kouts)

# “50% of edges covered by top out-degree nodes”
n = G.number_of_nodes()
m_edges = G.number_of_edges()
halfm = m_edges // 2
kouts_sorted = sorted(kouts, reverse=True)
cs_kouts = np.cumsum(kouts_sorted)
ind = int(np.searchsorted(cs_kouts, halfm)) + 1  # +1 for 1-based count
print(f'number of nodes, n  = {n}')
print(f'number of edges, m  = {m_edges}')
print(f'mean(k_in)  = {np.mean(kins):5.2f}')
print(f'mean(k_out) = {np.mean(kouts):5.2f}')
print(f'smallest num for 50%  = {ind} of {n} nodes')
