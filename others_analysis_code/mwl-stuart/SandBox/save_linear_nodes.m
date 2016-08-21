function save_linear_nodes(epoch_path, nodes) %#ok

    save(fullfile(epoch_path, 'track_nodes.mat'), 'nodes');

end