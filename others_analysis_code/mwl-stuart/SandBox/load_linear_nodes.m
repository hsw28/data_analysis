function nodes = load_linear_nodes(epoch_path)

    nodes = load(fullfile(epoch_path, 'track_nodes.mat'));
    nodes = nodes.nodes;
end