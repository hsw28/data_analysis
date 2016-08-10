function triangulation_demo()

% init source & sensor,  positions & strengths
% 4 sensors
sens_x = [-1, 1, -1, 1];
sens_y = [-1, -1, 1, 1];
sens_pos = [sens_x; sens_y];
%sens_x = 0;
%sens_y = 0;
%sens_pos = [sens_x; sens_y];

n_sens = numel(sens_x);
sens_pickup = ones(size(sens_x));

% 2 sources
%source_x = [-1:0.1:1];
%source_y = zeros(size(source_x));
%source_x = [source_x, zeros(1,numel(source_x)) ];
%source_y = [source_y, [-1:0.1:1 ]];

%source_x = [-3, -3, -3, 0, 0, 0, 3, 3, 3];
%source_y = [-3, 0, 3, -3, 0, 3, -3, 0, 3];
%source_x = repmat(source_x,1,10);
%source_y = repmat(source_y,1,10);

source_x = 0; source_y = 3;

source_pos = [source_x; source_y];
%source_x = 0;
%source_y = 1;
%source_pos = [source_x; source_y];

n_source = numel(source_x);
source_strength = ones(size(source_x));

% generate distances & corresponding signals
dists_mat = simple_dists(sens_pos, source_pos);
signals_mat = simple_generate_signals(dists_mat, sens_pickup, source_strength);

% 'Simulated annealing' loop

% make an initial guess at sens and source positions
[m_sens_pos, m_sens_pickup, m_source_pos, m_source_strength] = gen_rand_hypothesis(n_sens, n_source);

m_sens_pos = sens_pos + 0.00*randn(size(sens_pos));
m_source_pos = source_pos + 1*randn(size(source_pos));

m_dists = simple_dists( m_sens_pos, m_source_pos );
strains = simple_strains( m_dists, signals_mat );
score = simple_objective_fn(strains);
j = 0;
T = 2;

while(1)
    T = 0.999 * T
    % calculate strains on sensors & sources
    dists_mat = simple_dists(m_sens_pos,m_source_pos);
    strains = simple_strains(dists_mat, signals_mat);
    [m2_sens_pos,m2_sens_pickup,m2_source_pos,m2_source_strength] = simple_neighbor(m_sens_pos,m_sens_pickup,m_source_pos,m_source_strength,signals_mat,T);
    
    plot(m_sens_pos(1,:), m_sens_pos(2,:), 'bo'); hold on;
    plot(m_source_pos(1,:), m_source_pos(2,:),'b*');
    strains = simple_strains( simple_dists( m2_sens_pos, m2_source_pos), signals_mat );
    this_score = simple_objective_fn(strains);
    format_string = 'r';
    disp(['Current score: ', num2str(score*10000), '  this_score: ', num2str(this_score*10000)]);
    disp(num2str(score == this_score));
    if or((this_score < score), T > rand(1))
        score = this_score;
        m_sens_pos = m2_sens_pos;
        m_sens_pickup = m2_sens_pickup;
        m_source_pos = m2_source_pos;
        m_source_strength = m2_source_strength;
        format_string = 'g';
    end
    plot(m2_sens_pos(1,:), m2_sens_pos(2,:), [format_string,'o']);
    plot(m2_source_pos(1,:), m2_source_pos(2,:), [format_string,'*']);
    xlim([-5, 5]);
    ylim([-5, 5]); hold off;
    pause(0.01);
end