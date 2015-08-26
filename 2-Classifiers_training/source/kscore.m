function [score] = kscore(point,kcoords)

    eucl_dist = pdist([point; kcoords]);

    if (eucl_dist > 0)
        score = 1 / eucl_dist;
    else
        score = Inf;
    end
end