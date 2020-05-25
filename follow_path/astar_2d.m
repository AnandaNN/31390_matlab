function [ route ] = astar_2d( map, start, end_, length_cost )
    % Check if length_cost was given
    if ~exist('length_cost', 'var')
        length_cost = 1;
    end
    % Define the limits of the map
    max_x = length(map(:,1,1));
    max_y = length(map(1,:,1));

    % Children must be initalized to have nodes in it
    % The arrays keeping track of the nodes must initialized 
    % containing a node. These flags tells the first node in the
    % closed and children array to be put in directly
    first_closed = 1;
    first_children = 1;
    closed = [];
    children = [];

    % Create the first node at the start position
    parent_node = node;
    parent_node.position = start;
    parent_node.g = 0;
    parent_node.h = parent_node.calc_dist(end_);
    parent_node.f = parent_node.g + parent_node.h;

    % Flag used to skip nodes which is already added
    continue_flag = 0;

    % Slow the calculation down,
    % so it can be followed in real time
    pause on;

    % Keep running until the end point is reached
    while ~(parent_node.position(1) == end_(1) && ...
            parent_node.position(2) == end_(2))
        % Run through the surronding squares
        for x = -1:1
            for y = -1:1
                % Skip the node itself
                if ~(x == 0 && y == 0)
                    node_pos = [parent_node.position(1) + x, ...
                                parent_node.position(2) + y];
                    % Check if the children is within the map
                    if ~(node_pos(1) < 1 || node_pos(1) > max_x || ...
                         node_pos(2) < 1 || node_pos(2) > max_y)
                        % Check if the children is an obstacle
                        if ~(map(node_pos(1), node_pos(2)) == 1)
                            % Check if the node have been visited
                            for closed_i = 1:length(closed)
                                if node_pos == closed(closed_i).position
                                    % Note that this node is not 
                                    % to be added to children
                                    continue_flag = 1;
                                end
                            end
                            % Check if the node is already a child
                            for child_i = 1:length(children)
                                if node_pos == children(child_i).position
                                    % Check if the robot is taking a diagonal path
                                    if abs(x) + abs(y) == 2
                                        % If so, add diagonal cost
                                        g = parent_node.g + ...
                                            sqrt(length_cost^2*2);
                                    else
                                        % Otherwise add linear cost
                                        g = parent_node.g + ...
                                            length_cost;
                                    end
                                    % If this road to the child is shorter, then
                                    % update the child
                                    if g < children(child_i).g
                                        children(child_i).g = g;
                                        children(child_i).parent = parent_node;
                                        children(child_i).f = children(child_i).g + ...
                                                              children(child_i).h;
                                    end
                                    % Note that this node is not 
                                    % to be added to children
                                    continue_flag = 1;
                                end
                            end

                            % Check if this node should be skipped
                            if continue_flag == 1
                                continue_flag = 0;
                                continue
                            end

                            % Define the child node
                            temp_node = node;
                            % Note its parent
                            temp_node.parent = parent_node;
                            % Note its position
                            temp_node.position = node_pos;
                            % Calculate the node's g cost
                            % Check if the robot is taking a diagonal path
                            if abs(x) + abs(y) == 2
                                % If so, add diagonal cost
                                temp_node.g = parent_node.g + ...
                                              sqrt(length_cost^2*2);
                            else
                                % Otherwise add linear cost
                                temp_node.g = parent_node.g + ...
                                              length_cost;
                            end
                            % Calculate the distance from the node
                            % to the end point
                            temp_node.h = temp_node.calc_dist(end_);
                            % Calculate the total cost of the node
                            temp_node.f = temp_node.g + temp_node.h;

                            % Add the node to the children array
                            % Check if it is the first child
                            % being added
                            if first_children == 1 
                                first_children = 0;
                                children = [temp_node]; 
                            else
                                % Otherwise expand the children array
                                children(end+1) = temp_node;
                            end
                        end
                    end
                end
            end
        end

    % Add the parent node to the list of closed nodes
    if first_closed == 1
        first_closed = 0;
        closed = [parent_node]; 
    else
        closed(end+1) = parent_node;
    end
        % Choose the child node with the lowest f value
        lowest_f = 999999;
        lowest_child_i = -1;
        for child_i = 1:length(children)
            if children(child_i).f < lowest_f
                lowest_f = children(child_i).f;
                lowest_child_i = child_i;
            end
        end

        % Check if there still is routes avaliable 
        if length(children) == 0
           route = NaN;
           return
        end
        
        % Update the parent to the children
        % with the lowest f value
        parent_node = children(lowest_child_i);

        % Delete the new parent from the children
        children(lowest_child_i) = [];
    end

    % Find the route that the algorithm took
    % Init the route array
    route = [parent_node.position];
    % Keep going until the route is back at the start position
    while  ~(parent_node.position(1) == start(1) && ...
             parent_node.position(2) == start(2))
       % Update the route by going backwards through the parents
       parent_node = parent_node.parent;
       route = cat(1,route,parent_node.position);
    end

    route = flip(route)
    
end