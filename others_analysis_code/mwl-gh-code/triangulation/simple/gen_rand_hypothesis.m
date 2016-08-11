function [m_sens_pos, m_sens_pickup, m_source_pos, m_source_strength] = gen_rand_hypothesis(n_sens, n_source)
    m_sens_pos = randn(2,n_sens);
    m_sens_pickup = ones(1,n_sens);
    m_source_pos = randn(2,n_source);
    m_source_strength = ones(1,n_source);